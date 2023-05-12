# frozen_string_literal: true

describe ::Question::Ruby::Application::Repository do
  before { described_class.delete_all }

  describe '.create' do
    context 'when an application with the same name does not exist' do
      it 'creates a new application' do
        application = described_class.create(name: 'app_name', root_directory: '.')

        expect(application).to have_attributes(
          itself: be_a(::Question::Ruby::Application),
          root_directory: '.'
        )
      end
    end

    context 'when an application with the same name already exists' do
      it 'raises an error' do
        described_class.create(name: 'app_name', root_directory: '.')

        expect { described_class.create(name: 'app_name', root_directory: '.') }.to raise_error(described_class::AlreadyExistsError)
      end
    end
  end
end
