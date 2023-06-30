# frozen_string_literal: true

describe ::Holistic::LanguageServer::Lifecycle do
  describe "#accept?" do
    it "always returns true for 'exit'" do
      lifecycle = described_class.new

      expect(lifecycle.accept?("exit")).to be(true)

      lifecycle.waiting_initialized_event!

      expect(lifecycle.accept?("exit")).to be(true)

      lifecycle.initialized!

      expect(lifecycle.accept?("exit")).to be(true)

      lifecycle.shutdown!

      expect(lifecycle.accept?("exit")).to be(true)
    end

    it "returns true for 'initialize' if :waiting_initialize_event" do
      lifecycle = described_class.new

      expect(lifecycle.accept?("initialize")).to be(true)

      lifecycle.waiting_initialized_event!

      expect(lifecycle.accept?("initialize")).to be(false)

      lifecycle.initialized!

      expect(lifecycle.accept?("initialize")).to be(false)

      lifecycle.shutdown!

      expect(lifecycle.accept?("initialize")).to be(false)
    end

    it "returns true for 'initialized' if :waiting_initialized_event" do
      lifecycle = described_class.new

      expect(lifecycle.accept?("initialized")).to be(false)

      lifecycle.waiting_initialized_event!

      expect(lifecycle.accept?("initialized")).to be(true)

      lifecycle.initialized!

      expect(lifecycle.accept?("initialized")).to be(false)

      lifecycle.shutdown!

      expect(lifecycle.accept?("initialized")).to be(false)
    end

    it "returns true for 'shutdown' if :initialized" do
      lifecycle = described_class.new

      expect(lifecycle.accept?("shutdown")).to be(false)

      lifecycle.waiting_initialized_event!

      expect(lifecycle.accept?("shutdown")).to be(false)

      lifecycle.initialized!

      expect(lifecycle.accept?("shutdown")).to be(true)

      lifecycle.shutdown!

      expect(lifecycle.accept?("shutdown")).to be(false)
    end
  end
end
