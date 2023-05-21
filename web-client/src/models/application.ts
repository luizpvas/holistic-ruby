import { reactive } from "vue";

export interface Application {
  name: string;
  rootDirectory: string;
}

export const applications = reactive<Application[]>([]);
