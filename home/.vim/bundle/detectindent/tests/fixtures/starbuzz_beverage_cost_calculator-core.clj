(ns starbuzz-beverage-cost-calculator.core
  (:gen-class)
  (:require clojure.string
            [starbuzz-beverage-cost-calculator.map-map :refer [map-map-keys]]
            camel-snake-kebab.core ))


; domain data

(def type-of-beverage-base
  {:house-blend :coffee
   :espresso :coffee
   :decaf :coffee
   :green-tea :tea
   :oolong-tea :tea
   :black-tea :tea })

(def price-of-bases-at-different-sizes
  "for each base and then for each size, the price in cents"
  {:house-blend
   {:small 150, :medium 175, :large 190}
   :espresso
   {:small 160, :medium 180, :large 200}
   :decaf
   {:small 150, :medium 175, :large 190}
   :green-tea
   {:small 130, :medium 160, :large 175}
   :oolong-tea
   {:small 150, :medium 175, :large 190}
   :black-tea
   {:small 130, :medium 160, :large 175} })

(def price-of-ingredient
  "for each ingredient, the price in cents"
  {:milk 10
   :soy-milk 25
   :chocolate 20
   :peppermint 25
   :jasmine-flower 20
   :osmanthus-flower 30 })

(def allowed-ingredients-for-beverage-type
  "for each type of beverage base, the set of ingredients that may be added to it"
  {:coffee
   #{:milk :soy-milk :chocolate :peppermint}
   :tea
   #{:milk :jasmine-flower :osmanthus-flower} })

(def beverages-on-menu
  {:coffee
   {:base :house-blend, :ingredients []}
   :espresso
   {:base :espresso, :ingredients []}
   :decaf
   {:base :decaf, :ingredients []}
   :mocha
   {:base :espresso, :ingredients [:chocolate]}
   :decaf-mocha
   {:base :decaf, :ingredients [:chocolate]}
   :latte
   {:base :espresso, :ingredients [:milk]}
   :decaf-latte
   {:base :decaf, :ingredients [:milk]}
   :soy-latte
   {:base :espresso, :ingredients [:soy-milk]}
   :peppermint-mocha
   {:base :espresso, :ingredients [:chocolate :peppermint]}
   :green-tea
   {:base :green-tea, :ingredients []}
   :oolong-tea
   {:base :oolong-tea, :ingredients []}
   :black-tea
   {:base :black-tea, :ingredients []}
   :jasmine-tea
   {:base :green-tea, :ingredients [:jasmine-flower]}
   :osmanthus-green
   {:base :green-tea, :ingredients [:osmanthus-flower]}
   :osmanthus-black
   {:base :black-tea, :ingredients [:osmanthus-flower]}
   :tea-latte
   {:base :black-tea, :ingredients [:milk]} })


; reading input

(defn input-word-reader
  "create a function that takes a string and returns a value matching the string with a case-insensitive comparison, and also takes a function that handles errors and returns a replacement value given the word with no match"
  ([inputs] (input-word-reader inputs (fn [not-found-word] nil)))
  ([inputs unknown-word-replacement-fun]
   (let [lower-case-inputs (map-map-keys clojure.string/lower-case inputs)]
     (fn [input-word]
       (let [found-value
             (lower-case-inputs
              (clojure.string/lower-case input-word) )]
         (if found-value
           found-value
           (unknown-word-replacement-fun input-word) ))))))

(def PascalCaseString->keyword camel-snake-kebab.core/->HTTP-Header-Case-Keyword)

(def ingredient-with-name
  (input-word-reader PascalCaseString->keyword) )

(def read-size-from-word
  (input-word-reader
   {"small" :small, "medium" :medium, "large" :large}
   (fn [not-found-word]
     (println (str "unknown size " not-found-word "; assuming medium"))
     :medium )))

(def read-menu-beverage
  (input-word-reader
   #(beverages-on-menu (PascalCaseString->keyword %))
   (fn [not-found-word]
     (println (str "unknown beverage " not-found-word "; assuming coffee"))
     (beverages-on-menu :coffee) )))

(defn read-and-add-ingredients [starting-beverage input-ingredients]
  (update-in starting-beverage [:ingredients]
             (fn [original-ingredients]
               (let [read-ingredients
                     (remove nil? (map ingredient-with-name input-ingredients))
                     allowed-ingredients
                     (allowed-ingredients-for-beverage-type (type-of-beverage-base (:base starting-beverage)))
                     allowed-read-ingredients
                     (filter
                      (fn [ingredient]
                        (if (contains? allowed-ingredients ingredient)
                          true
                          (do
                            (println (str "ignoring ingredient " ingredient "; it is not allowed in this type of beverage"))
                            false )))
                      read-ingredients )]
                 (concat original-ingredients allowed-read-ingredients) ))))

(defn input-words []
  (clojure.string/split (read-line) #"\s") )

(defn beverage-from-input-words [input-words]
  (let [beverage-as-on-menu
        (read-menu-beverage (first input-words))
        beverage-including-custom-ingredients
        (read-and-add-ingredients beverage-as-on-menu (nthrest input-words 2))
        beverage-also-including-size
        (assoc
          beverage-including-custom-ingredients
          :size
          (read-size-from-word (second input-words)) )]
    beverage-also-including-size ))
;{:size :small, :base :house-blend, :ingredients [:milk :peppermint :milk]} )


; calculating beverage price

(defn price-of-beverage-before-ingredients [beverage]
  (let [base (:base beverage)
        size (:size beverage) ]
    (-> price-of-bases-at-different-sizes base size) ))

(defn price-of-ingredients [ingredients]
  (reduce
   (fn [current-price ingredient]
     (+ current-price (price-of-ingredient ingredient)))
   0 ingredients))

(defn price-of-beverage
  "price in cents of the beverage"
  [beverage]
  (+
   (price-of-beverage-before-ingredients beverage)
   (price-of-ingredients (:ingredients beverage)) ))


; outputting price

(defn format-price-as-string [price]
  (format "$%.2f" (double (/ price 100))) )



(defn -main
  "Ask for beverage and show its price"
  [& args]
  (println "Enter your order.")
  (println "format: <beverage name> <size> [<ingredient 1>, <ingredient 2>, ...]")
  (let [words (input-words)
        beverage (beverage-from-input-words words)
        price (price-of-beverage beverage)
        formatted-price (format-price-as-string price) ]
    (println "The price of that beverage:" formatted-price) ))
