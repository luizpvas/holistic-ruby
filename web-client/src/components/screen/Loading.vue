<template>
    <div>Loading...</div>
    <div>
        {{ applications }}
        {{ currentApplicationName }}
    </div>
</template>

<script lang="ts" setup>
import { fetchApplications, setCurrentApplicationName, currentApplicationName } from '../../models/application';

const applications = await fetchApplications();

setCurrentApplicationName(applications[0].name);
</script>
