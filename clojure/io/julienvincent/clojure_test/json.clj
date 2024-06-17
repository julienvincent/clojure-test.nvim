(ns io.julienvincent.clojure-test.json
  (:require
   [io.julienvincent.clojure-test.query :as api.query]
   [io.julienvincent.clojure-test.runner :as api.runner]
   [jsonista.core :as json]))

(defmacro ^:private with-json-out [& body]
  `(let [res# (do ~@body)]
     (json/write-value-as-string res# (json/object-mapper {:pretty true}))))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn get-test-namespaces []
  (with-json-out
    (api.query/get-test-namespaces)))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn get-tests-in-ns [namespace]
  (with-json-out
    (api.query/get-tests-in-ns namespace)))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn get-all-tests []
  (with-json-out
    (api.query/get-all-tests)))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn load-test-namespaces []
  (with-json-out
    (doseq [namespace (api.query/get-test-namespaces)]
      (require namespace))))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn run-test [test-sym]
  (with-json-out
    (api.runner/run-test test-sym)))

#_{:clj-kondo/ignore [:clojure-lsp/unused-public-var]}
(defn resolve-metadata-for-symbol [sym]
  (with-json-out
    (api.query/resolve-metadata-for-symbol sym)))
