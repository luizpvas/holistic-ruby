import { reactive, ref, watch } from "vue";
import { apiClient } from "./api";

export interface Application {
  name: string;
  root_directory: string;
}

export const applications = reactive<Application[]>([]);

export const currentApplicationName = ref<string | null>(null);

watch(currentApplicationName, (name) => {
  if (name === null) return;

  document.title = name;
});

export async function fetchApplications(): Promise<Application[]> {
  const response = await apiClient.get<Application[]>("/applications");

  applications.splice(0, applications.length, ...response.data);
  currentApplicationName.value = response.data[0].name;

  return applications;
}

export function getCurrentApplication(): Application {
  const app = applications.find(
    (app) => app.name === currentApplicationName.value
  );

  if (!app) {
    throw new Error("Current application not found");
  }

  return app;
}
