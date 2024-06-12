(ns io.julienvincent.clojure-test.api
  (:require
   [clj-commons.format.exceptions :as ex]
   [clojure.java.io :as io]
   [clojure.pprint :as pprint]
   [clojure.string :as str]
   [clojure.test :as test]
   [jsonista.core :as json])
  (:import
   java.io.File
   java.net.URI
   java.nio.file.Paths))

(defn- is-parent [parent child]
  (let [parent (-> (Paths/get (URI. (str "file://" parent)))
                   .toAbsolutePath
                   .normalize)
        child (-> (Paths/get (URI. (str "file://" child)))
                  .toAbsolutePath
                  .normalize)]

    (.startsWith child parent)))

(defn get-classpath []
  (into #{}
        (comp
         (filter (fn [path]
                   (let [file ((requiring-resolve 'clojure.java.io/file) path)]
                     (and (.exists file)
                          (.isDirectory file)))))
         (map (fn [path]
                (->> (File. path)
                     .getAbsolutePath
                     str)))
         (filter (fn [path]
                   (is-parent (System/getProperty "user.dir") path))))
        (str/split (System/getProperty "java.class.path") #":")))

(defn find-test-files []
  (mapcat
   (fn [dir]
     (let [files (file-seq (io/file dir))]
       (->> files
            (filter (fn [file]
                      (.isFile file)))
            (map (fn [file]
                   (subs (.getAbsolutePath file) (inc (count dir)))))

            (filter (fn [path]
                      (re-find #"_test.clj" path))))))
   (get-classpath)))

(defn get-test-namespaces []
  (let [test-files (find-test-files)]

    (map
     (fn [file]
       (let [without-ext (str/replace file #"\.clj" "")
             as-ns (-> without-ext
                       (str/replace #"/" ".")
                       (str/replace #"_" "-"))]
         (symbol as-ns)))

     test-files)))

(defn get-tests-in-ns [namespace]
  (require namespace)
  (into []
        (comp
         (filter
          (fn [[_ var]]
            (:test (meta var))))
         (map (fn [[sym]]
                (symbol (str namespace) (str sym)))))
        (ns-interns namespace)))

(defn get-all-tests []
  (mapcat get-tests-in-ns (get-test-namespaces)))

(defn load-test-namespaces []
  (doseq [namespace (get-test-namespaces)]
    (require namespace)))

(def ^:dynamic ^:private *report* nil)

(defn- parse-diff [diff]
  (when-let [mc (requiring-resolve 'matcher-combinators.config/disable-ansi-color!)]
    (mc))

  (cond
    (= :matcher-combinators.clj-test/mismatch (:type (meta diff)))
    (pr-str diff)

    :else
    (with-out-str
      (pprint/pprint diff))))

(defn- parse-report [report]
  (let [exception (when (instance? Throwable (:actual report))
                    (ex/analyze-exception (:actual report) {}))

        report (cond-> report
                 (:expected report)
                 (assoc :expected (parse-diff (:expected report)))

                 (not (:expected report))
                 (dissoc :expected)

                 (and (:actual report)
                      (not exception))
                 (assoc :actual (parse-diff (:actual report)))

                 (not (:actual report))
                 (dissoc :actual)

                 exception (assoc :exception exception)
                 exception (dissoc :actual))]

    (-> report
        (assoc :context test/*testing-contexts*)
        (dissoc :var :ns))))

(defn run-test [test-sym]
  (binding [*report* (atom [])]
    (with-redefs [test/report
                  (fn [report]
                    (swap! *report* conj (parse-report report)))]
      (test/run-test-var (resolve test-sym)))
    @*report*))

(defmacro ^:private with-json-out [& body]
  `(let [res# (do ~@body)]
     (json/write-value-as-string res# (json/object-mapper {:pretty true}))))

(defn get-test-namespaces-json []
  (with-json-out
    (get-test-namespaces)))

(defn get-tests-in-ns-json [namespace]
  (with-json-out
    (get-tests-in-ns namespace)))

(defn get-all-tests-json []
  (with-json-out
    (get-all-tests)))

(defn run-test-json [test-sym]
  (with-json-out
    (run-test test-sym)))
