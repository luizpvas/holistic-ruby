import { reactive, ref, watch } from "vue";
import { currentApplicationName } from "./application";
import { apiClient } from "./api";

interface Match {
  identifier: string;
  text: string;
  highlighted_text: string;
  score: number;
}

export function useSearch() {
  const query = ref<string>("");
  const matches: Match[] = reactive<Match[]>([]);

  function runSearch(query: string) {
    apiClient
      .get<Match[]>(`/applications/${currentApplicationName.value}/search`, {
        params: { query: query },
      })
      .then((response) => {
        matches.splice(0, matches.length, ...response.data);
      });
  }

  watch(query, runSearch);

  return { query, matches };
}
