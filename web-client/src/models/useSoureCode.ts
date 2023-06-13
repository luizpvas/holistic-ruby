import { currentApplicationName } from "./application";
import { apiClient } from "./api";
import { ref } from "vue";
import { Symbol } from "./symbol";

interface SourceCode {
  file_path: string;
  code: string;
  symbols: Symbol[];
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

  const write = (content: string) => {
    if (sourceCode.value === null) {
      throw new Error("source code is not loaded");
    }

    return apiClient
      .post<SourceCode>(
        `/applications/${currentApplicationName.value}/source_code`,
        {
          file_path: sourceCode.value.file_path,
          content: content,
        }
      )
      .then((response) => {
        sourceCode.value = response.data;
      });
  };

  return { sourceCode, write };
}
