# frozen_string_literal: true

describe ::Holistic::Ruby::Symbol::Outline do
	include ::SnippetParser

	let(:application) do
		parse_snippet <<~RUBY
		module MyApp
			PlusOne = ->(x) { x + 1 }

			module Example1; end
		
			class Example2
				def do_something; end
			end
		end
		RUBY
	end

	it "outlines a module with lots of declarations" do
		result = described_class.call(application:, symbol: application.symbols.find("::MyApp"))

		expect(result.dependants).to be_empty
		expect(result.references).to be_empty
		expect(result.dependencies).to be_empty

		expect(result.declarations.map(&:identifier)).to match_array([
			"::MyApp",
			"::MyApp::PlusOne",
			"::MyApp::Example1",
			"::MyApp::Example2",
			"::MyApp::Example2#do_something"
		])
	end
end