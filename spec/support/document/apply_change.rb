# frozen_string_literal: true

module Support
  module Document
    module ApplyChange
      def insert_text_on_document(document:, text:, line:, column:)
        change =
          ::Holistic::Document::Unsaved::Change.new(
            range_length: text.length,
            text:,
            start_line: line,
            start_column: column,
            end_line: line,
            end_column: column
          )
        
        document.apply_change(change)
      end

      def insert_new_line_on_document(document:, after_line:)
        column = document.content.split("\n")[after_line].length

        insert_text_on_document(document:, text: "\n", line: after_line, column:)
      end
    end
  end
end
