<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="nav-search search-product-container" style="position: relative; flex: 1; max-width: 440px;">
    <i id="searchIcon" class="fa-solid fa-magnifying-glass" style="position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--gray-400); font-size: 0.85rem; cursor: pointer;"></i>
    <% String currentSearch = request.getParameter("search"); %>
    <input type="text" id="searchInput" placeholder="Tìm kiếm trái cây, rau củ..." autocomplete="off" value="<%= currentSearch != null ? currentSearch.replace("\"", "&quot;") : "" %>" style="width: 100%; height: 40px; border: 1.5px solid var(--gray-200); border-radius: 100px; padding: 0 1rem 0 2.8rem; font-size: 0.875rem; font-family: 'Inter', sans-serif; background: var(--gray-50); color: var(--gray-800); outline: none; transition: all 0.2s;">
    <div id="searchDropdown" class="search-dropdown"></div>
</div>

<style>
    #searchInput:focus {
        border-color: var(--green, #4CAF50);
        background: var(--white, #ffffff);
        box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
    }
    .search-dropdown {
        position: absolute;
        top: 100%;
        left: 0;
        width: 100%;
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        margin-top: 4px;
        z-index: 1000;
        display: none;
        max-height: 400px;
        overflow-y: auto;
    }
    .search-dropdown.active {
        display: block;
    }
    .search-item {
        display: flex;
        align-items: center;
        padding: 10px;
        border-bottom: 1px solid #f3f4f6;
        text-decoration: none;
        color: #1f2937;
        transition: background 0.2s;
    }
    .search-item:last-child {
        border-bottom: none;
    }
    .search-item:hover {
        background: #f9fafb;
    }
    .search-item img {
        width: 40px;
        height: 40px;
        object-fit: cover;
        border-radius: 4px;
        margin-right: 12px;
    }
    .search-item-info {
        flex: 1;
    }
    .search-item-title {
        font-size: 0.9rem;
        font-weight: 500;
        margin-bottom: 4px;
    }
    .search-item-price {
        font-size: 0.85rem;
        color: #10b981;
        font-weight: 600;
    }
    .search-no-result {
        padding: 12px;
        text-align: center;
        color: #6b7280;
        font-size: 0.9rem;
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const searchDropdown = document.getElementById('searchDropdown');
    let debounceTimer;

    searchInput.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        const query = this.value.trim();
        
        if (query.length === 0) {
            searchDropdown.classList.remove('active');
            return;
        }

        debounceTimer = setTimeout(() => {
            fetch('<%= request.getContextPath() %>/search-suggest?q=' + encodeURIComponent(query))
                .then(response => response.json())
                .then(data => {
                    searchDropdown.innerHTML = '';
                    if (data.length === 0) {
                        searchDropdown.innerHTML = '<div class="search-no-result">Không tìm thấy sản phẩm nào</div>';
                    } else {
                        data.forEach(item => {
                            const priceFormatted = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.salePrice);
                            const imgUrl = item.image ? '<%= request.getContextPath() %>/image?type=product&id=' + item.id : '<%= request.getContextPath() %>/images/default-product.png';
                            
                            const a = document.createElement('a');
                            a.href = '<%= request.getContextPath() %>/info?id=' + item.id;
                            a.className = 'search-item';
                            a.innerHTML = 
                                '<img src="' + imgUrl + '" alt="' + item.title + '">' +
                                '<div class="search-item-info">' +
                                    '<div class="search-item-title">' + item.title + '</div>' +
                                    '<div class="search-item-price">' + priceFormatted + '</div>' +
                                '</div>';
                            searchDropdown.appendChild(a);
                        });
                    }
                    searchDropdown.classList.add('active');
                })
                .catch(err => console.error('Search error:', err));
        }, 300);
    });

    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            triggerSearch();
        }
    });

    document.getElementById('searchIcon').addEventListener('click', function() {
        triggerSearch();
    });

    function triggerSearch() {
        const query = searchInput.value.trim();
        if (query.length > 0) {
            window.location.href = '<%= request.getContextPath() %>/home.jsp?search=' + encodeURIComponent(query);
        }
    }

    document.addEventListener('click', function(e) {
        if (!searchInput.contains(e.target) && !searchDropdown.contains(e.target)) {
            searchDropdown.classList.remove('active');
        }
    });
});
</script>
