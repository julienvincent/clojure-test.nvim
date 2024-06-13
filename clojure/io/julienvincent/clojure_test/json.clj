(ns io.julienvincent.clojure-test.json
  (:require
   [io.julienvincent.clojure-test.query :as api.query]
   [io.julienvincent.clojure-test.runner :as api.runner]
   [jsonista.core :as json]))

(defmacro ^:private with-json-out [& body]
  `(let [res# (do ~@body)]
     (json/write-value-as-string res# (json/object-mapper {:pretty true}))))

(defn get-test-namespaces []
  (with-json-out
    (api.query/get-test-namespaces)))

(defn get-tests-in-ns [namespace]
  (with-json-out
    (api.query/get-tests-in-ns namespace)))

(defn get-all-tests []
  (with-json-out
    (api.query/get-all-tests)))

(defn load-test-namespaces []
  (doseq [namespace (api.query/get-test-namespaces)]
    (require namespace)))

(defn run-test [test-sym]
  (with-json-out
    (api.runner/run-test test-sym)))
