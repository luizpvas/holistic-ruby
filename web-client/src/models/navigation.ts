import { Component, reactive, ref } from "vue";

export interface Screen {
  title: string;
  component: Component;
}

export interface Track {
  currentStackIndex: number;
  screens: Screen[];
}

export const tracks = reactive<Track[]>([]);

export const currentTrackIndex = ref<number>(0);

export function pushTrack(title: string, component: Component) {
  const screen: Screen = { title, component };

  tracks.push({
    currentStackIndex: 0,
    screens: [screen],
  });
}
