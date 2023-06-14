<template>
  <div class="max-w-[700px] mx-auto p-4">
    <input
      ref="searchInput"
      class="block w-full p-2 border-2 rounded-full"
      v-model="query"
      placeholder="Search..."
    />

    {{ result?.elapsed_time_in_seconds }}

    <ul>
      <li v-for="match in result?.matches">
        <Action @click="navigateToSourceCode($event, match.identifier)">
          <span v-html="match.highlighted_text"></span>
          {{ match.score }}
        </Action>
      </li>
    </ul>
  </div>
</template>

<style scope>
em {
  background-color: yellow;
  font-style: normal;
  font-weight: bold;
}
</style>

<script setup lang="ts">
import { h, onMounted, ref, watch } from "vue";
import {
  replaceCurrentScreen,
  updateCurrenTitle,
} from "../../models/navigation";
import { useSearch } from "../../models/useSearch";
import Action from "../Action.vue";
import SourceCode from "./SourceCode.vue";

const searchInput = ref<HTMLInputElement | null>(null);

const { query, result } = useSearch();

watch(query, () => {
  updateCurrenTitle(`search: ${query.value}`);
});

function navigateToSourceCode(_event: MouseEvent, identifier: string) {
  const component = h(SourceCode, { identifier });

  replaceCurrentScreen(`source: ${identifier}`, component);
}

onMounted(() => {
  searchInput.value?.focus();
});
</script>
