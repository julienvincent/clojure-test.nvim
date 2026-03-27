(ns io.julienvincent.clojure-test.serialization
  (:require
   [io.julienvincent.clojure-test.query :as query]
   [clj-commons.format.exceptions :as pretty.exceptions]
   [clojure.pprint :as pprint]))

(defn- remove-commas
  "Clojures pprint function adds commas in whitespace. This removes them while
   maintaining any commas that are within strings"
  [s]
  (let [pattern #"(?<=^|[^\\])(\"(?:[^\"\\]|\\.)*\"|[^,\"]+)|(,)"
        matches (re-seq pattern s)]
    (apply str (mapv
                (fn [[_ group1]]
                  (or group1 ""))
                matches))))

(defn- pretty-print [data]
  (-> (with-out-str
        (pprint/pprint data))
      remove-commas))

(defn parse-diff [diff]
  (when-let [mc (try (requiring-resolve 'matcher-combinators.config/disable-ansi-color!)
                     (catch Exception _))]
    (mc))

  (cond
    (= :matcher-combinators.clj-test/mismatch (:type (meta diff)))
    (-> diff pr-str remove-commas)

    :else
    (pretty-print diff)))

(defn- with-frame-locations [stack-trace]
  (mapv
   (fn [frame]
     (let [package (:package frame)
           frame-name (first (:names frame))
           location (some (fn [sym]
                            (when sym
                              (query/resolve-metadata-for-symbol sym)))
                          [frame-name package])]
       (assoc frame :location location)))
   stack-trace))

(defn analyze-exception [exception]
  (mapv
   (fn [{:keys [properties stack-trace] :as ex}]
     (let [props (when properties
                   (pretty-print properties))
           stack-trace (with-frame-locations stack-trace)]

       (merge ex
              {:properties (or props properties)
               :stack-trace stack-trace})))

   (pretty.exceptions/analyze-exception exception {})))
