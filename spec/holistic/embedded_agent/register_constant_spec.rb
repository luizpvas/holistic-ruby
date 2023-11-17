# frozen_string_literal: true

require "spec_helper"

describe ::Holistic::EmbeddedAgent::Event do
  describe "register_constant" do
    let(:application) do
      ::Holistic::Application.boot(name: "app", root_directory: ".")
    end

    it "registers a class" do
      application.bridge.publish("register_constant", {
        fully_qualified_lexical_parent: nil,
        name: "String",
        kind: "class"
      })

      scope = application.scopes.find("::String")
      expect(scope.kind).to eq(::Holistic::Ruby::Scope::Kind::CLASS)
      expect(scope.locations.external?).to be(true)
    end

    context "when registering a module"
    context "when registering an object"
  end
end
