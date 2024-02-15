<x-dashboard-layout>

    <a href="{{ route('add-product') }}" wire:navigate
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded block w-fit shadow-md shadow-gray-500/70">
        <i class="fa-solid fa-plus"></i>
        Add Product
    </a>

    <div class="relative overflow-x-auto shadow-md sm:rounded-lg mt-4">
        <x-table>
            <x-table-head :headers="['name', 'category', 'price', 'Available', 'quantity', 'status', 'action']" />
            <x-table-body />
        </x-table>
    </div>

</x-dashboard-layout>
