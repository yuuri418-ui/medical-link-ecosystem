pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chartkick", to: "chartkick.js"
pin "chart.js", to: "chart.js"
pin "chartjs-adapter-date-fns", to: "chartjs-adapter-date-fns.js"
pin "stimulus" # @3.2.2
