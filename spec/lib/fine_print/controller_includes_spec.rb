require 'spec_helper'

module FinePrint
  describe ControllerIncludes do
    it 'must add fine_print_sign to ActionController instances' do
      expect(ActionController::Base.new.respond_to? :fine_print_sign).to eq true
      expect(DummyModelsController.new.respond_to? :fine_print_sign).to eq true
    end

    it 'must add fine_print_return to ActionController instances' do
      expect(ActionController::Base.new.respond_to?(:fine_print_return, true)).to eq true
      expect(DummyModelsController.new.respond_to?(:fine_print_return, true)).to eq true
    end

    it 'must add fine_print_require to ActionController and subclasses' do
      expect(ActionController::Base.respond_to? :fine_print_require).to eq true
      expect(DummyModelsController.respond_to? :fine_print_require).to eq true
    end

    it 'must add fine_print_skip to ActionController and subclasses' do
      expect(ActionController::Base.respond_to? :fine_print_skip).to eq true
      expect(DummyModelsController.respond_to? :fine_print_skip).to eq true
    end
  end
end
