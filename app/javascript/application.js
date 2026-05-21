// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "likes"

// ActionCable setup
import * as ActionCable from "@rails/actioncable"

window.App ||= {}
App.cable = ActionCable.createConsumer()
