document.addEventListener('DOMContentLoaded', function () {
    document.body.addEventListener('click', function (event) {
        var button = event.target.closest('[data-wishlist-action]');
        if (!button) {
            return;
        }
        event.preventDefault();
        var action = button.dataset.wishlistAction;
        var productId = button.dataset.productId;
        if (!productId) {
            return;
        }
        if (action === 'add') {
            ajaxPost('/add-to-wishlist', { productId: productId }, function () {
                window.location.reload();
            });
            return;
        }
        if (action === 'remove') {
            ajaxPost('/remove-wishlist', { productId: productId }, function () {
                window.location.reload();
            });
            return;
        }
        if (action === 'move') {
            ajaxPost('/move-wishlist-to-cart', { productId: productId }, function () {
                window.location.href = '/wishlist';
            });
        }
    });
});

function ajaxPost(url, data, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            callback(xhr.responseText);
        }
    };
    xhr.send(serialize(data));
}

function serialize(obj) {
    var str = [];
    for (var p in obj) {
        if (obj.hasOwnProperty(p) && obj[p] != null) {
            str.push(encodeURIComponent(p) + '=' + encodeURIComponent(obj[p]));
        }
    }
    return str.join('&');
}
