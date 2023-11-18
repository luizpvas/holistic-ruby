# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::EmbeddedAgent::Event do
  describe "register_constant" do
    let(:application) do
      ::Holistic::Application.boot(name: "app", root_directory: ".")
    end

    it "registers a class on the root scope" do
      application.bridge.publish("register_constant", {
        fully_qualified_lexical_parent: nil,
        name: "String",
        kind: "class"
      })

      scope = application.scopes.find("::String")
      expect(scope.kind).to eq(::Holistic::Ruby::Scope::Kind::CLASS)
      expect(scope.locations.external?).to be(true)
    end

    it "registers a class in a namespace" do
      application.bridge.publish("register_constant", {
        fully_qualified_lexical_parent: nil,
        name: "Payment",
        kind: "class"
      })

      application.bridge.publish("register_constant", {
        fully_qualified_lexical_parent: "::Payment",
        name: "Charge",
        kind: "class"
      })

      scope = application.scopes.find("::Payment::Charge")
      expect(scope.kind).to eq(::Holistic::Ruby::Scope::Kind::CLASS)
      expect(scope.locations.external?).to be(true)
    end

    it "registers a module in the root scope" do
      application.bridge.publish("register_constant", {
        fully_qualified_lexical_parent: nil,
        name: "Utils",
        kind: "module"
      })

      scope = application.scopes.find("::Utils")
      expect(scope.kind).to eq(::Holistic::Ruby::Scope::Kind::MODULE)
      expect(scope.locations.external?).to be(true)
    end

    context "when registering an object" do
    end
  end
end
