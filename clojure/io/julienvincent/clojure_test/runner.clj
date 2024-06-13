(ns io.julienvincent.clojure-test.runner
  (:require
   [clj-commons.format.exceptions :as ex]
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
