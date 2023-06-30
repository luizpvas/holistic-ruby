# strings_are_not_frozen_on_purpose

describe ::Holistic::LanguageServer::Requests::TextDocument::DidChange do
  let(:source_code_before) do
    <<~RUBY
    # frozen_string_literal: true

    module Holistic
      VERSION = "0.1.0"
    end
    RUBY
  end

  let(:source_code_after) do
    <<~RUBY
    # frozen_string_literal: true

    module Holistic
      # Some comment here
      def plus_one(x)
        x + 1
      end
    end
    RUBY
  end

  let(:file_path) { "my_app/example.rb" }

  let(:did_open_payload) do
    {"method"=>"textDocument/didOpen", "jsonrpc"=>"2.0", "params"=>{"textDocument"=>{"uri"=>"file://#{file_path}", "languageId"=>"ruby", "text"=>"# frozen_string_literal: true\n\nmodule Holistic\n  VERSION = \"0.1.0\"\nend\n", "version"=>0}}}
  end

  let(:did_change_payloads) do
    [
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"\n", "range"=>{"end"=>{"character"=>19, "line"=>3}, "start"=>{"character"=>19, "line"=>3}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>4}, "start"=>{"character"=>0, "line"=>4}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>2}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"\n", "range"=>{"end"=>{"character"=>2, "line"=>4}, "start"=>{"character"=>2, "line"=>4}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>5}, "start"=>{"character"=>0, "line"=>5}}}, {"rangeLength"=>2, "text"=>"", "range"=>{"end"=>{"character"=>2, "line"=>4}, "start"=>{"character"=>0, "line"=>4}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>5}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"d", "range"=>{"end"=>{"character"=>2, "line"=>5}, "start"=>{"character"=>2, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>3, "line"=>5}, "start"=>{"character"=>3, "line"=>5}}}, {"rangeLength"=>0, "text"=>"f", "range"=>{"end"=>{"character"=>4, "line"=>5}, "start"=>{"character"=>4, "line"=>5}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>5, "line"=>5}, "start"=>{"character"=>5, "line"=>5}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>9}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"p", "range"=>{"end"=>{"character"=>6, "line"=>5}, "start"=>{"character"=>6, "line"=>5}}}, {"rangeLength"=>0, "text"=>"l", "range"=>{"end"=>{"character"=>7, "line"=>5}, "start"=>{"character"=>7, "line"=>5}}}, {"rangeLength"=>0, "text"=>"u", "range"=>{"end"=>{"character"=>8, "line"=>5}, "start"=>{"character"=>8, "line"=>5}}}, {"rangeLength"=>0, "text"=>"s", "range"=>{"end"=>{"character"=>9, "line"=>5}, "start"=>{"character"=>9, "line"=>5}}}, {"rangeLength"=>0, "text"=>"_", "range"=>{"end"=>{"character"=>10, "line"=>5}, "start"=>{"character"=>10, "line"=>5}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>14}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"o", "range"=>{"end"=>{"character"=>11, "line"=>5}, "start"=>{"character"=>11, "line"=>5}}}, {"rangeLength"=>0, "text"=>"n", "range"=>{"end"=>{"character"=>12, "line"=>5}, "start"=>{"character"=>12, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>13, "line"=>5}, "start"=>{"character"=>13, "line"=>5}}}, {"rangeLength"=>0, "text"=>"()", "range"=>{"end"=>{"character"=>14, "line"=>5}, "start"=>{"character"=>14, "line"=>5}}}, {"rangeLength"=>0, "text"=>"x", "range"=>{"end"=>{"character"=>15, "line"=>5}, "start"=>{"character"=>15, "line"=>5}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>19}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"\n", "range"=>{"end"=>{"character"=>17, "line"=>5}, "start"=>{"character"=>17, "line"=>5}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>6}, "start"=>{"character"=>0, "line"=>6}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>2, "line"=>6}, "start"=>{"character"=>2, "line"=>6}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>4, "line"=>6}, "start"=>{"character"=>4, "line"=>6}}}, {"rangeLength"=>0, "text"=>"n", "range"=>{"end"=>{"character"=>5, "line"=>6}, "start"=>{"character"=>5, "line"=>6}}}, {"rangeLength"=>0, "text"=>"d", "range"=>{"end"=>{"character"=>6, "line"=>6}, "start"=>{"character"=>6, "line"=>6}}}, {"rangeLength"=>4, "text"=>"", "range"=>{"end"=>{"character"=>4, "line"=>6}, "start"=>{"character"=>0, "line"=>6}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>6}, "start"=>{"character"=>0, "line"=>6}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>27}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"\n", "range"=>{"end"=>{"character"=>2, "line"=>6}, "start"=>{"character"=>2, "line"=>6}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>7}, "start"=>{"character"=>0, "line"=>7}}}, {"rangeLength"=>2, "text"=>"", "range"=>{"end"=>{"character"=>2, "line"=>6}, "start"=>{"character"=>0, "line"=>6}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>30}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"    ", "range"=>{"end"=>{"character"=>0, "line"=>6}, "start"=>{"character"=>0, "line"=>6}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>31}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"x", "range"=>{"end"=>{"character"=>4, "line"=>6}, "start"=>{"character"=>4, "line"=>6}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>5, "line"=>6}, "start"=>{"character"=>5, "line"=>6}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>33}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"+", "range"=>{"end"=>{"character"=>6, "line"=>6}, "start"=>{"character"=>6, "line"=>6}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>7, "line"=>6}, "start"=>{"character"=>7, "line"=>6}}}, {"rangeLength"=>0, "text"=>"1", "range"=>{"end"=>{"character"=>8, "line"=>6}, "start"=>{"character"=>8, "line"=>6}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>36}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"\n", "range"=>{"end"=>{"character"=>0, "line"=>4}, "start"=>{"character"=>0, "line"=>4}}}, {"rangeLength"=>0, "text"=>"  ", "range"=>{"end"=>{"character"=>0, "line"=>5}, "start"=>{"character"=>0, "line"=>5}}}, {"rangeLength"=>0, "text"=>"#", "range"=>{"end"=>{"character"=>2, "line"=>5}, "start"=>{"character"=>2, "line"=>5}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>3, "line"=>5}, "start"=>{"character"=>3, "line"=>5}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>40}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>0, "text"=>"S", "range"=>{"end"=>{"character"=>4, "line"=>5}, "start"=>{"character"=>4, "line"=>5}}}, {"rangeLength"=>0, "text"=>"o", "range"=>{"end"=>{"character"=>5, "line"=>5}, "start"=>{"character"=>5, "line"=>5}}}, {"rangeLength"=>0, "text"=>"m", "range"=>{"end"=>{"character"=>6, "line"=>5}, "start"=>{"character"=>6, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>7, "line"=>5}, "start"=>{"character"=>7, "line"=>5}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>8, "line"=>5}, "start"=>{"character"=>8, "line"=>5}}}, {"rangeLength"=>0, "text"=>"c", "range"=>{"end"=>{"character"=>9, "line"=>5}, "start"=>{"character"=>9, "line"=>5}}}, {"rangeLength"=>0, "text"=>"o", "range"=>{"end"=>{"character"=>10, "line"=>5}, "start"=>{"character"=>10, "line"=>5}}}, {"rangeLength"=>0, "text"=>"m", "range"=>{"end"=>{"character"=>11, "line"=>5}, "start"=>{"character"=>11, "line"=>5}}}, {"rangeLength"=>0, "text"=>"m", "range"=>{"end"=>{"character"=>12, "line"=>5}, "start"=>{"character"=>12, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>13, "line"=>5}, "start"=>{"character"=>13, "line"=>5}}}, {"rangeLength"=>0, "text"=>"n", "range"=>{"end"=>{"character"=>14, "line"=>5}, "start"=>{"character"=>14, "line"=>5}}}, {"rangeLength"=>0, "text"=>"t", "range"=>{"end"=>{"character"=>15, "line"=>5}, "start"=>{"character"=>15, "line"=>5}}}, {"rangeLength"=>0, "text"=>" ", "range"=>{"end"=>{"character"=>16, "line"=>5}, "start"=>{"character"=>16, "line"=>5}}}, {"rangeLength"=>0, "text"=>"h", "range"=>{"end"=>{"character"=>17, "line"=>5}, "start"=>{"character"=>17, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>18, "line"=>5}, "start"=>{"character"=>18, "line"=>5}}}, {"rangeLength"=>0, "text"=>"r", "range"=>{"end"=>{"character"=>19, "line"=>5}, "start"=>{"character"=>19, "line"=>5}}}, {"rangeLength"=>0, "text"=>"e", "range"=>{"end"=>{"character"=>20, "line"=>5}, "start"=>{"character"=>20, "line"=>5}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>57}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>20, "text"=>"", "range"=>{"end"=>{"character"=>19, "line"=>3}, "start"=>{"character"=>15, "line"=>2}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>58}}},
      {"method"=>"textDocument/didChange", "jsonrpc"=>"2.0", "params"=>{"contentChanges"=>[{"rangeLength"=>1, "text"=>"", "range"=>{"end"=>{"character"=>0, "line"=>3}, "start"=>{"character"=>15, "line"=>2}}}], "textDocument"=>{"uri"=>"file://#{file_path}", "version"=>59}}}
    ]
  end

  let(:application) { ::Holistic::Application.new(name: "dummy", root_directory: ".") }

  around(:each) { |each| ::Holistic::LanguageServer::Current.set(application:, &each) }

  it "applies delta changes to the document in memory" do
    did_open_message = ::Holistic::LanguageServer::Message.new(did_open_payload)

    ::Holistic::LanguageServer::Router.dispatch(did_open_message)

    expect(application.unsaved_documents.find(file_path)).to have_attributes(
      content: source_code_before
    )

    did_change_payloads.each do |did_change_payload|
      did_change_message = ::Holistic::LanguageServer::Message.new(did_change_payload)
      ::Holistic::LanguageServer::Router.dispatch(did_change_message)
    end

    expect(application.unsaved_documents.find(file_path)).to have_attributes(
      content: source_code_after
    )
  end
end
