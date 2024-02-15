<?php

use Illuminate\Support\Facades\Route;
use Livewire\Volt\Volt;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::view('/', 'welcome');

Route::middleware(['auth', 'verified', 'can:isAdmin'])->group(function () {
    Route::view('orders', 'dashboard.orders')->name('orders');
    Route::view('products', 'dashboard.product')->name('product');
    Volt::route('customer', 'customer.index')->name('customer');
    Route::view('dashboard', 'dashboard.index')->name('dashboard');

    Volt::route('add-product', 'product.add-product')->name('add-product');
});

Route::view('profile', 'profile')
    ->middleware(['auth'])
    ->name('profile');

require __DIR__.'/auth.php';
