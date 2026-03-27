(ns io.julienvincent.clojure-test.serialization-test
  (:require
   [clojure.test :refer [deftest is]]
   [io.julienvincent.clojure-test.serialization :as serialization]
   [io.julienvincent.clojure-test.test.example :as test.example]
   [io.julienvincent.clojure-test.test.example.child-module :as test.example.child-module]
   [matcher-combinators.matchers :as m]
   [matcher-combinators.test]))

(deftest analyze-exception-test
  (try
    (test.example/throws)
    (is false "Should never reach here")
    (catch Exception ex
      (is (match? [{:class-name "clojure.lang.ExceptionInfo"
                    :message "Wrapped"
                    :properties "{:data 2}\n"
                    :stack-trace []}
                   {:class-name "clojure.lang.ExceptionInfo"
                    :message "Bad"
                    :properties "{:data 1}\n"
                    :stack-trace
                    (m/prefix [{:simple-class string?
                                :package "io.julienvincent.clojure_test.test"
                                :is-clojure? true
                                :method "invokeStatic"
                                :name "io.julienvincent.clojure-test.test.example/throws-inner"
                                :file "example.clj"
                                :line 4
                                :id "io.julienvincent.clojure-test.test.example/throws-inner:4"
                                :class "io.julienvincent.clojure_test.test.example$throws_inner"
                                :location {:file #".*clojure/test/io/julienvincent/clojure_test/test/example.clj"}
                                :names ["io.julienvincent.clojure-test.test.example"
                                        "throws-inner"]}
                               {:package "io.julienvincent.clojure_test.test"
                                :is-clojure? true
                                :method "invokeStatic"
                                :name "io.julienvincent.clojure-test.test.example/throws"
                                :file "example.clj"
                                :line 7
                                :id "io.julienvincent.clojure-test.test.example/throws:7"
                                :class "io.julienvincent.clojure_test.test.example$throws"
                                :location
                                {:file #".*/clojure/test/io/julienvincent/clojure_test/test/example.clj"}
                                :names
                                ["io.julienvincent.clojure-test.test.example"
                                 "throws"]}])}]
                  (serialization/analyze-exception ex))))))

(deftest analyze-exception-child-module-test
  (try
    (test.example.child-module/throws)
    (is false "Should never reach here")
    (catch Exception ex
      (is (match? [{:class-name "clojure.lang.ExceptionInfo"
                    :message "Thrown from child module"
                    :properties "{:sum 2}\n"
                    :stack-trace
                    (m/prefix [{:simple-class "child_module$throws"
                                :package "io.julienvincent.clojure_test.test.example"
                                :is-clojure? true
                                :method "invokeStatic"
                                :name
                                "io.julienvincent.clojure-test.test.example.child-module/throws"
                                :file "child_module.clj"
                                :line 5
                                :id
                                "io.julienvincent.clojure-test.test.example.child-module/throws:5"
                                :class
                                "io.julienvincent.clojure_test.test.example.child_module$throws"
                                :location {:file #".*/clojure/test/io/julienvincent/clojure_test/test/example/child_module.clj"}
                                :names ["io.julienvincent.clojure-test.test.example.child-module"
                                        "throws"]}])}]

                  (serialization/analyze-exception ex))))))
