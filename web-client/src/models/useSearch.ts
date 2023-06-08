import { ref, watch } from "vue";
import { currentApplicationName } from "./application";
import { apiClient } from "./api";

interface Match {
  identifier: string;
  text: string;
  highlighted_text: string;
  score: number;
}

interface Result {
  elapsed_time_in_seconds: number;
  matches: Match[];
}

export function useSearch() {
  const query = ref<string>("");
  const result = ref<Result | null>(null);

  function runSearch(query: string) {
    apiClient
      .get<Result>(`/applications/${currentApplicationName.value}/search`, {
        params: { query: query },
      })
      .then((response) => {
        result.value = response.data;
      });
  }

  watch(query, runSearch);

  return { query, result };
}
