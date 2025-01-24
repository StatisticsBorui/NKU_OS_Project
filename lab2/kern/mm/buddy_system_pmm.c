#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    unsigned size = 1;
    while (size <= n) {
        size <<= 1;
    }
    size >>= 1;
    struct Page *p = base;
    unsigned index = 0;
    for (; p != base + size; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        p -> location = index;
        index++;
    }
    base -> property = size;
    base -> location = 0;
    SetPageProperty(base);
    nr_free += size;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } 
    else{
        assert(0);
    }
    /*
    else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }*/
}

static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        struct Page *p = NULL;
        
        while(page -> property / 2 >= n){
            list_entry_t* next = list_next(&(page -> page_link));
            list_del(&(page -> page_link));
            p = page + page -> property / 2;
            p -> property = page -> property / 2;
            SetPageProperty(p);
            list_add_before(next, &(p -> page_link));
            page -> property /= 2;
            list_add_before(&(p -> page_link), &(page -> page_link));
        }
        list_del(&(page->page_link));
        nr_free -= page -> property;
        ClearPageProperty(page);
    }
    return page;
}

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    unsigned flag = 0;
    while(p -> property == 0) {
        p--;
        flag++;
    }
    unsigned size = p -> property;
    assert(flag + n <= size);
    struct Page *b = p;
    for (; p != b + size; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    //b->property = size;
    SetPageProperty(b);
    nr_free += size;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(b->page_link));
    } 
    else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            p = le2page(le, page_link);
            if (b < p) {
                list_add_before(le, &(b->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(b->page_link));
                break;
            }
        }
    } 

    while(1) {
        if (((b -> location / b -> property) & 1 )
         && b -> page_link.prev != &free_list
         && (le2page(b -> page_link.prev,page_link) -> location == b -> location - size)
         && (b-size) -> property == size) {
            p = b - size;
            p -> property *= 2;
            ClearPageProperty(b);
            b -> property = 0;
            list_del(&(b -> page_link));
            b = p;
            size *= 2;
        }
        else if (!((b -> location / b -> property) & 1 )
         && b -> page_link.next != &free_list
         && (le2page(b -> page_link.next,page_link) -> location == b -> location + size)
         && ((b+size) -> property == size)) {
            p = b + size;
            b -> property *= 2;
            ClearPageProperty(p);
            p -> property = 0;
            list_del(&(p -> page_link));
            size *= 2;
         }
        else{
            break;
        }
    }
}

static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);
    
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
   
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
  
    assert(nr_free == 3);
 
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
  
    
    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
    
    basic_check();


    struct Page *p0 = alloc_pages(7), *p1 = alloc_pages(13), *p2 = alloc_pages(5);
    assert(p0 != NULL);
    assert(!PageProperty(p0));
    assert(p1 != NULL);
    assert(!PageProperty(p1));
    assert(p2 != NULL);
    assert(!PageProperty(p2));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0,2);
    assert(!list_empty(&free_list));
    free_pages(p1,5);


    assert(alloc_pages(18) == NULL);
    assert(!list_empty(&free_list));
    free_pages(p2,1);
    
    p0 = alloc_pages(18);
    assert(p0 != NULL);
    assert(nr_free == 0);

    free_pages(p0 + 3, 3);
    assert(nr_free == 32);


    p0 = alloc_pages(14);
    p1 = alloc_page();
    p2 = alloc_pages(6);
    assert(nr_free == 7);

    free_page(p1 - 1);
    assert(PageProperty(p0));
    assert(nr_free == 23);
    free_page(p2);
    assert(nr_free == 31);
    free_page(p1);
    assert(nr_free == 32);

    p0 = alloc_pages(7);
    p1 = alloc_pages(13);
    p2 = alloc_pages(5);

    nr_free = nr_free_store;
    free_list = free_list_store;

    free_page(p0);
    free_page(p1);
    free_page(p2);
    

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);

}
//这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};





