require 'spec_helper'

module FinePrint
  describe ControllerAdditions do
    it 'must add fine_print_get_signatures to ActionController and subclasses' do
      expect(ActionController::Base.respond_to? :fine_print_get_signatures).to eq true
      expect(DummyModelsController.respond_to? :fine_print_get_signatures).to eq true
    end

    it 'must add fine_print_skip_signatures to ActionController and subclasses' do
      expect(ActionController::Base.respond_to? :fine_print_skip_signatures).to eq true
      expect(DummyModelsController.respond_to? :fine_print_skip_signatures).to eq true
    end

    it 'must add fine_print_return to ActionController instances' do
      expect(ActionController::Base.new.respond_to?(:fine_print_return, true)).to eq true
      expect(DummyModelsController.new.respond_to?(:fine_print_return, true)).to eq true
    end
  end
end
