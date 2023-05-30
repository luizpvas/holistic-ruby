<template>
  <div class="p-4">
    <input class="border p-2" v-model="query" />

    <ul>
      <li v-for="match in matches">
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
import { h, watch } from "vue";
import { pushScreen, updateCurrenTitle } from "../../models/navigation";
import { useSearch } from "../../models/useSearch";
import Action from "../Action.vue";
import SourceCode from "./SourceCode.vue";

const { query, matches } = useSearch();

watch(query, () => {
  updateCurrenTitle(`search: ${query.value}`);
});

function navigateToSourceCode(_event: MouseEvent, identifier: string) {
  const component = h(SourceCode, { identifier });

  pushScreen(`source: ${identifier}`, component);
}
</script>
