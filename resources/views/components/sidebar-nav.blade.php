@props(['active'])

@php
    $classes = $active ?? false ? 'flex items-center gap-3 rounded-lg px-4 py-2 text-gray-900 bg-gray-200 transition-all hover:text-gray-900' : 'flex items-center gap-3 rounded-lg px-4 py-2 text-gray-600 transition-all hover:text-gray-900';
@endphp

<a {{ $attributes->merge(['class' => $classes]) }}>
    {{ $slot }}
</a>
