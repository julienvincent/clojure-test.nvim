(ns io.julienvincent.clojure-test.runner
  (:require
   [clj-commons.format.exceptions :as pretty.exceptions]
   [clojure.pprint :as pprint]
   [clojure.test :as test]))

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

(defn- parse-exception [exception]
  (mapv
   (fn [{:keys [properties] :as ex}]
     (let [props (when properties
                   (with-out-str
                     (pprint/pprint properties)))]
       (if props
         (assoc ex :properties props)
         ex)))
   (pretty.exceptions/analyze-exception exception {})))

(defn- parse-report [report]
  (let [exception (when (instance? Throwable (:actual report))
                    (parse-exception (:actual report)))

        report (cond-> (select-keys report [:type])
                 (:expected report)
                 (assoc :expected (parse-diff (:expected report)))

                 (and (:actual report)
                      (not exception))
                 (assoc :actual (parse-diff (:actual report)))

                 exception (assoc :exception exception))]

    (assoc report :context test/*testing-contexts*)))

(defn run-test [test-sym]
  (binding [*report* (atom [])]
    (with-redefs [test/report
                  (fn [report]
                    (swap! *report* conj (parse-report report)))]
      (test/run-test-var (resolve test-sym)))
    @*report*))
