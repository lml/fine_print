require 'spec_helper'

module FinePrint
  module ActionController
    RSpec.describe Base, type: :lib do
      let!(:controller)       { ::ActionController::Base.new }
      let!(:dummy_controller) { DummyModelsController.new }

      it 'must add fine_print_sign to ActionController instances' do
        expect(controller).to respond_to(:fine_print_require)
        expect(dummy_controller).to respond_to(:fine_print_require)
      end

      it 'must add fine_print_return to ActionController instances' do
        expect(controller.respond_to?(:fine_print_return, true)).to eq true
        expect(dummy_controller.respond_to?(:fine_print_return, true)).to eq true
      end

      it 'must add fine_print_require to ActionController and subclasses' do
        expect(controller.class).to respond_to(:fine_print_require)
        expect(dummy_controller.class).to respond_to(:fine_print_require)
      end

      it 'must add fine_print_skip to ActionController and subclasses' do
        expect(controller.class).to respond_to(:fine_print_skip)
        expect(dummy_controller.class).to respond_to(:fine_print_skip)
      end
    end
  end
end
