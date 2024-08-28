(ns io.julienvincent.clojure-test.runner
  (:require
   [clj-commons.format.exceptions :as pretty.exceptions]
   [clojure.pprint :as pprint]
   [clojure.test :as test]))

(def ^:dynamic ^:private *report* nil)

(defn- remove-commas
  "Clojures pprint function adds commas in whitespace. This removes them while maintaining
  any commas that are within strings"
  [s]
  (let [pattern #"(?<=^|[^\\])(\"(?:[^\"\\]|\\.)*\"|[^,\"]+)|(,)"
        matches (re-seq pattern s)]
    (apply str (map
                (fn [[_ group1]]
                  (or group1 ""))
                matches))))

(defn pretty-print [data]
  (-> (with-out-str
        (pprint/pprint data))
      remove-commas))

(defn- parse-diff [diff]
  (when-let [mc (try (requiring-resolve 'matcher-combinators.config/disable-ansi-color!)
                     (catch Exception _))]
    (mc))

  (cond
    (= :matcher-combinators.clj-test/mismatch (:type (meta diff)))
    (-> diff pr-str remove-commas)

    :else
    (pretty-print diff)))

(defn- parse-exception [exception]
  (mapv
   (fn [{:keys [properties] :as ex}]
     (let [props (when properties
                   (pretty-print properties))]
       (if props
         (assoc ex :properties props)
         ex)))
   (pretty.exceptions/analyze-exception exception {})))

(defn- parse-report [report]
  (let [exceptions (when (instance? Throwable (:actual report))
                     (parse-exception (:actual report)))

        report (cond-> (select-keys report [:type])
                 (:expected report)
                 (assoc :expected (parse-diff (:expected report)))

                 (and (:actual report)
                      (not exceptions))
                 (assoc :actual (parse-diff (:actual report)))

                 exceptions (assoc :exceptions exceptions))]

    (assoc report :context test/*testing-contexts*)))

(defn run-test [test-sym]
  (binding [*report* (atom [])]
    (with-redefs [test/report
                  (fn [report]
                    (swap! *report* conj (parse-report report)))]
      (test/run-test-var (resolve test-sym)))
    @*report*))
