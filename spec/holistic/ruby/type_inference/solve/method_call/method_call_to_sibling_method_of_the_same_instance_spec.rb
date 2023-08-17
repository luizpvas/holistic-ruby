# frozen_string_literal: true

describe ::Holistic::Ruby::TypeInference::Solve do
  include ::Support::SnippetParser

  context "when calling a method in the same class" do
    let(:application) do
      parse_snippet <<~RUBY
      class Calculator
        def sum(a, b)
          a + b
        end

        def plus(a, b)
          sum(a, b)
        end
      end
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("sum")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::Calculator#sum"
      )
    end
  end

  context "when calling a private method in the same class" do
    let(:application) do
      parse_snippet <<~RUBY
      class EventsController < ApplicationController
        def index
          events = search_events_from_request_params
        end

        private

        def search_events_from_request_params
          Event.search(params)
        end
      end
      RUBY
    end

    it "solves the method call reference" do
      reference = application.references.find_by_code_content("search_events_from_request_params")

      expect(reference.conclusion).to have_attributes(
        status: :done,
        dependency_identifier: "::EventsController#search_events_from_request_params"
      )
    end
  end
end
