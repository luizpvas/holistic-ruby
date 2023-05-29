import { currentApplicationName } from "./application";
import { apiClient } from "./api";
import { ref } from "vue";

interface SourceCode {
  file_path: string;
  code: string;
  highlight_start_line: number;
  highlight_end_line: number;
}

export function useSourceCode(symbolIdentifier: string) {
  const sourceCode = ref<SourceCode | null>(null);

  apiClient
    .get<SourceCode>(
      `/applications/${currentApplicationName.value}/source_code`,
      {
        params: {
          symbol_identifier: symbolIdentifier,
        },
      }
    )
    .then((response) => {
      sourceCode.value = response.data;
    });

  return { sourceCode };
}
