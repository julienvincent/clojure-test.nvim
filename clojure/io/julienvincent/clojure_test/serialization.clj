(ns io.julienvincent.clojure-test.serialization
  (:require
   [clj-commons.format.exceptions :as pretty.exceptions]
   [clojure.pprint :as pprint]))

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

(defn analyze-exception [exception]
  (mapv
   (fn [{:keys [properties] :as ex}]
     (let [props (when properties
                   (pretty-print properties))]
       (if props
         (assoc ex :properties props)
         ex)))
   (pretty.exceptions/analyze-exception exception {})))
