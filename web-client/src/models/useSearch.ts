import { reactive } from "vue";
import { currentApplicationName } from "./application";
import { apiClient } from "./api";

export function useSearch() {
  const rootNamespaces: string[] = reactive<string[]>([]);

  apiClient
    .get(`/applications/${currentApplicationName.value}/namespaces`)
    .then((response) => {
      const rootNamespace = response.data["::"];

      Object.keys(rootNamespace).forEach((namespace) => {
        rootNamespaces.push(namespace);
      });
    });

  return { rootNamespaces };
}
