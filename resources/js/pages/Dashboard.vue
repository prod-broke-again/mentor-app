<script setup lang="ts">
import { Head } from '@inertiajs/vue3';
import PlaceholderPattern from '@/components/PlaceholderPattern.vue';
import { dashboard } from '@/routes';

defineOptions({
    layout: {
        breadcrumbs: [
            {
                title: 'Dashboard',
                href: dashboard(),
            },
        ],
    },
});
</script>

<template>
    <Head title="Dashboard" />

    <div
        class="flex h-full flex-1 flex-col gap-4 overflow-x-auto rounded-2xl p-4"
    >
        <div class="grid auto-rows-min gap-4 md:grid-cols-3">
            <div
                class="relative aspect-video overflow-hidden rounded-2xl border border-border/70 bg-card/60 shadow-soft dark:border-border"
            >
                <PlaceholderPattern />
            </div>
            <div
                class="relative aspect-video overflow-hidden rounded-2xl border border-border/70 bg-card/60 shadow-soft dark:border-border"
            >
                <PlaceholderPattern />
            </div>
            <div
                class="relative aspect-video overflow-hidden rounded-2xl border border-border/70 bg-card/60 shadow-soft dark:border-border"
            >
                <PlaceholderPattern />
            </div>
        </div>
        <div
            class="relative min-h-[100vh] flex-1 rounded-2xl border border-border/70 bg-card/40 shadow-soft md:min-h-min dark:border-border"
        >
            <PlaceholderPattern />
        </div>
    </div>
</template>
