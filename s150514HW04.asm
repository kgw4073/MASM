TITLE BUGHOUSE
;	프로그램 작성자 : 20150514 김건우
;	기능 : 주어진 위치에 벌레가 몇 마리 살고 있는지 구함.
;	입력 : R, C (행과 열) 좌표
;	출력 : 주어진 좌표에 있는 벌레 수

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter R: ", 0							;	행과 열을 입력받기 위한 문자열
prompt2 BYTE "Enter C: ", 0							;
column_num = 10										;	열의 개수를 Equal-Sign Directive를 통해 선언
H DWORD 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 120 DUP(?)	;	H 배열의 원소는 130개이고 첫 10개의 원소는 알려져 있지만 이후에는 계산해야 하므로 DUP을 통해 선언 
Ro DWORD ?											;	행과 열의 인덱스를 저장하기 위한 변수
Co DWORD ?

.code
main PROC
	mov edx, OFFSET prompt1			;	19~26행은 Ro와 Co에 탐색할 행과 열의 인덱스를 입력받기 위한 코드
	call WriteString
	call ReadDec
	mov RO, eax
	mov edx, OFFSET prompt2
	call WriteString
	call ReadDec
	mov CO, eax

	mov ecx, 12						;	첫 번째 루프를 열 두번 돌며 위에서 선언된 나머지 120개의 원소를 채울 것이다.
	mov edi, 0						;	edi는 H로부터 떨어진 OFFSET을 저장하기 위함
	L1:
		mov esi, OFFSET H			;	esi에 H의 OFFSET 값을 저장 
		add esi, edi				;	H의 OFFSET 값에 edi를 더하여 esi가 가리키는 원소는 더해야 할 원소(즉, 직전 행) 
		mov eax, [esi]
		mov ebx, ecx				;	각 행에 대해서, 루프를 한 번 더 돌며 계산하고 저장해야 하기 때문에 현재 ecx를 임시 저장
		mov ecx, column_num			;	따라서 열의 개수를 ecx에 할당
		add edi, TYPE H*column_num	;	계산해야 할 원소는 다음 행이므로 다음 행의 OFFSET을 edi에 저장
		L2:
			mov H[edi], eax			;	다음 행은 직전 행에서의 해당 열까지의 합이므로
			add edi, TYPE H			;	다음 원소의 OFFSET을 위해 TYPE H를 더함
			add esi, TYPE H			;	직전 행의 원소 OFFSET도 TYPE H를 더해주어야 함
			add eax, [esi]			;	현재 esi값(직전 행의 원소)값을 eax에 더해주고 루프를 돌며 H[edi]에 저장
			loop L2

		mov ecx, ebx				;	두 번째 루프가 끝났으므로 ebx에 저장했던 첫 번째 루프 횟수를 불러옴
		sub edi, TYPE H*column_num	;	edi에서 TYPE H*10을 빼주는 이유는 현재 edi는 더해야 할 행 다음 행을 가리키므로 직전 행으로 바꿔주어야 하기 때문이다.
		loop L1

	mov ecx, Ro						;	입력받은 행과 열을 row-major-order로 계산하기 위한 작업이다.
	mov eax, 0

	L3:
		add eax, TYPE H*column_num	;	행의 개수*TYPE H*Ro를 계산하기 위한 루프이다.
		loop L3

	mov ebx, eax					;	ebx에 현재까지 계산된 주소를 옮긴다.
	sub ebx, TYPE H					;	ebx에서 TYPE H를 한 번 빼는 이유는 Co로 1이 들어올 때를 위함이다. Co로 1이 들어오면 TYPE H를 더하지 않는 상태가 되어야 하기 때문.
	mov ecx, Co						;	Co만큼 루프를 돌며 TYPE H를 더해감. 만약 1이 들어오면 이미 직전에 TYPE H를 빼주었기 때문에 원 상태가 된다.
	L4:
		add ebx, TYPE H
		loop L4

	mov edi, ebx					;	최종적으로 ebx에는 row-major-order로 계산한 OFFSET값이 저장되어 있다. 따라서 edi에 옮기고 H[edi]를 하면 해당 위치의 벌레 수가 나온다.
	mov eax, H[edi]
	call WriteDec
	exit
main ENDP
END main