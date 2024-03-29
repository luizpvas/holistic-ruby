# frozen_string_literal: true

describe ::Holistic::Ruby::Parser::LiveEditing::ProcessFileChanged do
  include ::Support::SnippetParser

  let(:source_code_before) do
    <<~RUBY
    module MyApp
      module Payment
        def self.call; end
      end

      Payment.call
    end
    RUBY
  end

  let(:source_code_after) do
    "any invalid ? ruby syntax here"
  end

  let(:application) { parse_snippet(source_code_before) }

  context "when file has an invalid syntax" do
    it "does not lose reference to existing code" do
      before_payment_scope = application.scopes.find("::MyApp::Payment")
      before_payment_call_reference = application.references.find_by_code_content("Payment.call")

      described_class.call(application:, file_path: "/snippet.rb", content: source_code_after)

      after_payment_scope = application.scopes.find("::MyApp::Payment")
      after_payment_call_reference = application.references.find_by_code_content("Payment.call")

      expect(after_payment_scope).to be(before_payment_scope)
      expect(after_payment_call_reference).to be(before_payment_call_reference)
    end
  end
end
