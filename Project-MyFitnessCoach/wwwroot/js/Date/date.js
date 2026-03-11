// Encapsulate all code to avoid top-level declarations (prevents duplicate 'let' SyntaxError)
(function () {
    if (window.__dateModuleLoaded) return;
    window.__dateModuleLoaded = true;

    // Full frontend schedule UI logic
    if (typeof dayjs !== 'undefined') dayjs.locale('zh-tw');

    let treeData = null;
    const nodeMap = {};
    let existingDataFromDB = [];
    const L = (window.__labels || {
        monthSeparatorYear: '年',
        monthSeparatorMonth: '月',
        firstWeek: '第一週',
        weekPrefix: '第',
        weekSuffix: '週',
        slots: ['(早)', '(午)', '(晚)'],
        fullMonthOpen: '全月開放預約',
        savedMark: '(已存)',
        noneSelected: '尚未選擇任何時段',
        noSelectionAlert: '尚未選擇時段！',
        savingText: '資料儲存中...',
        saveSuccess: '成功！時段已寫入資料庫。',
        saveFailed: '儲存失敗，請檢查網路狀態或伺服器。',
        confirmSubmit: '確認送出設定',
        readOnlyText: '已送出 (唯讀模式)'
    });

    // 新增：初始化時計算全選狀態
    function refreshCheckedState(node) {
        if (node.children && node.children.length > 0) {
            node.children.forEach(refreshCheckedState);
            node.checked = node.children.every(child => child.checked);
        }
    }

    function generateCurrentMonthData() {
        const today = dayjs();
        const startOfMonth = dayjs().startOf('month');
        const daysInMonth = startOfMonth.daysInMonth();

        const root = {
            id: startOfMonth.format('YYYY-MM'),
            label: startOfMonth.format('YYYY') + L.monthSeparatorYear + ' ' + startOfMonth.format('M') + L.monthSeparatorMonth,
            level: 'month',
            checked: false, disabled: false, children: [], parent: null
        };

        let currentWeek = {
            id: `W1`, label: L.firstWeek, level: 'week',
            checked: false, disabled: false, children: [], parent: root
        };

        const slotExpireHours = [9, 14, 18];

        for (let i = 0; i < daysInMonth; i++) {
            const date = startOfMonth.add(i, 'day');
            const isPastDay = date.isBefore(today, 'day');

            const dayNode = {
                id: date.format('YYYY-MM-DD'),
                label: date.format('M/D (dd)'),
                level: 'day', checked: false, disabled: false,
                children: [], parent: currentWeek
            };

            const slots = ['09-10 ' + L.slots[0], '14-15 ' + L.slots[1], '18-19 ' + L.slots[2]];
            slots.forEach((slotLabel, index) => {
                const slotId = `${dayNode.id}-S${index}`;
                const isBooked = existingDataFromDB.includes(slotId);

                let isSlotPast = false;
                if (isPastDay) {
                    isSlotPast = true;
                } else if (date.isSame(today, 'day')) {
                    isSlotPast = today.hour() >= slotExpireHours[index];
                }

                dayNode.children.push({
                    id: slotId,
                    label: slotLabel,
                    level: 'slot',
                    checked: isBooked,
                    disabled: isSlotPast,
                    isBooked: isBooked,
                    parent: dayNode
                });
            });

            currentWeek.children.push(dayNode);

            if (date.day() === 6 || i === daysInMonth - 1) {
                root.children.push(currentWeek);
                if (i < daysInMonth - 1) {
                    currentWeek = {
                        id: `W${root.children.length + 1}`, label: `第 ${root.children.length + 1} 週`,
                        level: 'week', checked: false, disabled: false, children: [], parent: root
                    };
                }
            }
        }

        refreshCheckedState(root); // 初始化全選狀態
        refreshDisabledState(root);
        return root;
    }

    function refreshDisabledState(node) {
        if (node.children && node.children.length > 0) {
            node.children.forEach(refreshDisabledState);
            node.disabled = node.children.every(child => child.disabled);
        }
    }

    function buildNodeMap(node) {
        nodeMap[node.id] = node;
        if (node.children) node.children.forEach(buildNodeMap);
    }

    function renderApp() {
        let html = '';

        html += `
            <div class="alert alert-success d-flex align-items-center month-control shadow-sm mb-4">
                <input class="form-check-input me-3 mt-0" type="checkbox" id="${treeData.id}" onchange="handleCheck('${treeData.id}')"
                    ${treeData.checked ? 'checked' : ''} ${treeData.disabled ? 'disabled' : ''}>
                <label class="mb-0 cursor-pointer" for="${treeData.id}">${treeData.label} - ${L.fullMonthOpen}</label>
            </div>
        `;

        // 佈局修正：每兩週一行
        html += `<div class="row row-cols-1 row-cols-lg-2 g-4">`;

        treeData.children.forEach(weekNode => {
            const weekColorClass = weekNode.checked ? 'text-danger fw-bold' : 'text-success';

            html += `
                <div class="col">
                    <div class="card h-100 shadow-sm border-0">
                        <div class="card-header week-header bg-success bg-opacity-10 ${weekColorClass} d-flex align-items-center border-bottom-0">
                            <input class="form-check-input me-2 mt-0" type="checkbox" id="${weekNode.id}" onchange="handleCheck('${weekNode.id}')"
                                ${weekNode.checked ? 'checked' : ''} ${weekNode.disabled ? 'disabled' : ''}>
                            <label class="mb-0 cursor-pointer" for="${weekNode.id}">${weekNode.label}</label>
                        </div>
                        <div class="card-body p-0">
            `;

            weekNode.children.forEach(dayNode => {
                const dayColorClass = dayNode.checked ? 'text-danger fw-bold' : 'text-dark';

                html += `<div class="d-flex align-items-center p-2 border-bottom day-row-hover">`;

                html += `
                    <div class="day-label d-flex align-items-center ${dayColorClass}">
                        <input class="form-check-input me-2 mt-0" type="checkbox" id="${dayNode.id}" onchange="handleCheck('${dayNode.id}')"
                            ${dayNode.checked ? 'checked' : ''} ${dayNode.disabled ? 'disabled' : ''}>
                        <label class="mb-0 cursor-pointer fw-medium" for="${dayNode.id}">${dayNode.label}</label>
                    </div>
                `;

                html += `<div class="d-flex justify-content-around flex-grow-1">`;
                dayNode.children.forEach(slotNode => {
                    const textColor = slotNode.isBooked ? 'text-danger fw-bold' : 'text-secondary';
                    const displayText = slotNode.isBooked ? `${slotNode.label} ${L.savedMark}` : slotNode.label;

                    html += `
                        <label class="d-flex align-items-center p-1 rounded cursor-pointer slot-item-hover mb-0 ${textColor}">
                            <input class="form-check-input me-1 mt-0" type="checkbox" id="${slotNode.id}" onchange="handleCheck('${slotNode.id}')"
                                ${slotNode.checked ? 'checked' : ''} ${slotNode.disabled ? 'disabled' : ''}>
                            <span style="font-size: 0.9em;">${displayText}</span>
                        </label>
                    `;
                });
                html += `</div></div>`;
            });

            html += `</div></div></div>`;
        });

        html += `</div>`;
        const appEl = document.getElementById('app');
        if (appEl) appEl.innerHTML = html;

        renderResults();
    }

    window.handleCheck = function (nodeId) {
        const node = nodeMap[nodeId];
        if (!node || node.disabled) return;

        const newStatus = !node.checked;
        updateChildren(node, newStatus);
        updateParent(node.parent);
        renderApp();
    }

    function updateChildren(node, status) {
        if (!node.disabled) node.checked = status;
        if (node.children) node.children.forEach(child => updateChildren(child, status));
    }

    function updateParent(parentNode) {
        if (!parentNode) return;

        const siblings = parentNode.children;
        const validSiblings = siblings.filter(child => !child.disabled);
        const allChecked = validSiblings.length > 0 && validSiblings.every(child => child.checked);

        parentNode.checked = allChecked;
        updateParent(parentNode.parent);
    }

    function renderResults() {
        const listEl = document.getElementById('selected-list');
        const result = [];

        function traverse(node) {
            if (node.level === 'slot' && node.checked) {
                result.push(`${node.parent.label} ${node.label}`);
            }
            if (node.children) node.children.forEach(traverse);
        }
        traverse(treeData);

        if (!listEl) return;

        if (result.length === 0) {
            listEl.innerHTML = `<span class="text-secondary fst-italic">${L.noneSelected}</span>`;
        } else {
            listEl.innerHTML = result.map(text =>
                `<span class="badge rounded-pill bg-info text-dark fw-normal fs-6 border border-info-subtle">${text}</span>`
            ).join('');
        }
    }

    async function submitData(btn) {
        const urlParams = new URLSearchParams(window.location.search);
        const instructorId = parseInt(urlParams.get('instructorId'));

        const payload = [];
        function collectData(node) {
            if (node.level === 'slot' && node.checked) {
                payload.push({
                    Date: node.parent.id,
                    Time_Slot: node.label.trim(),
                    InstructorId: instructorId
                });
            }
            if (node.children) node.children.forEach(collectData);
        }
        collectData(treeData);

        if (payload.length < 1) {
            const alertMsg = L.noSelectionAlert || "請至少選擇一個預約時段才能送出！";
            alert(alertMsg);
            return;
        }

        const originalText = btn.innerHTML;
        btn.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>${L.savingText}`;
        btn.disabled = true;

        try {
            const response = await fetch('/Shift/Submit', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                const msg = errorData.message || 'API Response Error';
                throw new Error(msg);
            }

            alert(L.saveSuccess);
            location.reload(); // 送出成功後重整頁面

        } catch (error) {
            console.error('Submit Error:', error);
            // 優先顯示後端傳回的具體錯誤訊息
            alert(error.message || L.saveFailed);
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    }

    function toggleEditMode() {
        lockForm(false);

        const submitBtn = document.getElementById('btn-submit');
        if (submitBtn) {
            submitBtn.innerText = L.confirmSubmit;
            submitBtn.disabled = false;
            submitBtn.style.display = 'block';
        }
        const editBtn = document.getElementById('btn-edit');
        if (editBtn) editBtn.style.display = 'none';
    }

    function lockForm(shouldLock) {
        const today = dayjs();
        const slotExpireHours = [9, 14, 18];

        function traverse(node) {
            if (shouldLock) {
                node.disabled = true;
            } else {
                if (node.level === 'slot') {
                    const nodeDate = dayjs(node.parent.id);
                    const isPastDay = nodeDate.isBefore(today, 'day');
                    const slotIndex = node.parent.children.findIndex(c => c.id === node.id);

                    let isSlotPast = false;
                    if (isPastDay) {
                        isSlotPast = true;
                    } else if (nodeDate.isSame(today, 'day')) {
                        isSlotPast = today.hour() >= slotExpireHours[slotIndex];
                    }
                    node.disabled = isSlotPast;
                } else {
                    node.disabled = false;
                }
            }
            if (node.children) node.children.forEach(traverse);
        }

        traverse(treeData);

        if (!shouldLock) {
            refreshDisabledState(treeData);
        }

        renderApp();
    }

    async function init() {
        try {
            // 不再需要從 URL 傳參數，後端會直接從登入資訊中識別使用者
            const response = await fetch('/Shift/GetBookedSlots');
            if (response.ok) {
                const data = await response.json();
                existingDataFromDB = data.bookedSlots || [];
                const remainingChances = data.remainingChances ?? 3;

                // 更新剩餘次數顯示
                const chancesEl = document.getElementById('remaining-chances');
                const submitBtn = document.getElementById('btn-submit');
                
                if (chancesEl) {
                    chancesEl.innerText = remainingChances;
                    
                    // 如果次數為 0，禁用送出按鈕
                    if (remainingChances <= 0) {
                        if (submitBtn) {
                            submitBtn.disabled = true;
                            submitBtn.classList.remove('btn-primary');
                            submitBtn.classList.add('btn-secondary');
                            submitBtn.innerHTML = '<i class="bi bi-x-circle me-1"></i>次數已達上限';
                        }
                        // 將提示框變色
                        chancesEl.parentElement.parentElement.classList.remove('alert-info');
                        chancesEl.parentElement.parentElement.classList.add('alert-danger');
                    }
                }

                console.log('Booked slots from DB:', existingDataFromDB);
                console.log('Remaining chances:', remainingChances);
            } else {
                console.error('Could not fetch booked slots');
            }
        } catch (error) {
            console.error('Connection error:', error);
        } finally {
            treeData = generateCurrentMonthData();
            buildNodeMap(treeData);
            renderApp();
        }
    }

    // expose some functions globally so the inline handlers work
    window.toggleEditMode = toggleEditMode;
    window.lockForm = lockForm;
    window.submitData = submitData;

    // run init
    document.addEventListener('DOMContentLoaded', () => init());
})();
