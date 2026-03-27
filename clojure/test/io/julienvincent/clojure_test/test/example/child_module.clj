(ns io.julienvincent.clojure-test.test.example.child-module)

(defn throws []
  (let [sum (+ 1 1)]
    (throw (ex-info "Thrown from child module" {:sum sum}))))
