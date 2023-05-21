import { Component, reactive } from "vue";

export interface Screen {
  title: string;
  component: Component;
}

export type Stack = Screen[];

export type Track = Stack[];

export const track = reactive<Track>([]);
