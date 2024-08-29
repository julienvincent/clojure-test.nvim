(ns io.julienvincent.clojure-test.runner
  (:require
   [clojure.test :as test]
   [io.julienvincent.clojure-test.serialization :as serialization]))

(def ^:dynamic ^:private *report* nil)

(defn- parse-report [report]
  (let [exceptions (when (instance? Throwable (:actual report))
                     (serialization/analyze-exception (:actual report)))

        report (cond-> (select-keys report [:type])
                 (:expected report)
                 (assoc :expected (serialization/parse-diff (:expected report)))

                 (and (:actual report)
                      (not exceptions))
                 (assoc :actual (serialization/parse-diff (:actual report)))

                 exceptions (assoc :exceptions exceptions))]

    (assoc report :context test/*testing-contexts*)))

(defn run-test [test-sym]
  (binding [*report* (atom [])]
    (with-redefs [test/report
                  (fn [report]
                    (swap! *report* conj (parse-report report)))]
      (test/run-test-var (resolve test-sym)))
    @*report*))
