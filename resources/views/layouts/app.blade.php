<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&family=Poppins:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="font-poppins w-full bg-gray-100 dark:bg-gray-900">
    <div class="bg-gray-700 h-6 flex justify-center items-center">
        <h3 class="text-xs font-medium uppercase text-white font-montserrat">all product 40% off
            <span class="underline ms-1 cursor-pointer">shop now</span>
        </h3>
    </div>
    <livewire:layout.header>

        <main class="mx-5 mt-6">
            {{ $slot }}
        </main>


        <script src="https://kit.fontawesome.com/9bc2b1b0f3.js" crossorigin="anonymous"></script>
</body>

</html>
