TITLE MINIMUM_LABOR
;프로그램 작성자 : (단독) 20150514 김건우
;설명 : 주어진 파일에 대해 각 테스트 케이스에 대해 MINIMUM_LABOR_TIME을 계산하여 출력한다. 수행할 수 없다면 -1을 출력한다.
;		첫 번째 줄에 과제들의 소요시간이 주어지고 두 번째 줄에는 과제 수행 가능일마다 과제를 수행할 수 있는 시간이 주어진다.
;		주어진 과제에 대해 한 개라도 수행할 수 없다면 -1을 출력하고 모두 수행할 수 있다면 소요 시간중 최소를 출력한다.
;		해당 프로그램은 루프가 한 번 돌때마다 Min Labor Time을 찾아서 Greedy Method를 이용하였다.

;입력 : redirection을 통한 in.txt
;출력 : out.txt

INCLUDE Irvine32.inc
.STACK 4096

CR=0Dh
LF=0Ah
MAX_SIZE=100	;	한 줄에 최대 100개 정도의 문자가 들어올 수 있다. (이유는 '31 24 24 24 .. 와 같이 총 3개의 문자가 32번 반복= 최대 96개의 문자)
MAX_NUM_STR=4	;	24가 최대 31번 반복되어 최대 744가 출력될 수 있다. 그래서 적절히 문자열의 크기를 4로 정하였다.
MAX_INT_LIST=32	;	최대 TASK의 개수는 31이며 가장 앞에 개수를 나타내는 문자까진 최대 32개의 정수를 받아야 한다.
.data
new_line BYTE 0Dh, 0Ah, 0
space BYTE " "	;	숫자 중간에 공백을 출력하기 위함.

EXIT_TEM BYTE "-1"

.data?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE MAX_SIZE DUP(?)	;	파일의 한 줄을 읽기 위한 버퍼

IntList DWORD MAX_INT_LIST DUP(?)	;	첫 번째 줄, 즉, 과제마다 걸리는 시간을 담은 정수리스트
IntList2 DWORD MAX_INT_LIST DUP(?)	;	두 번째 줄, 즉, 수행 가능일마다 수행할 수 있는 시간을 담은 정수리스트

StrBuf BYTE MAX_NUM_STR DUP(?)	;	StrBuf는 IntToStr함수에서 하나의 문자열을 출력하기 위한 버퍼


.code

Read_a_Line PROC	
; Read_a_Line 함수에서 edi reg를 통해 숫자에 해당하는 문자를 세는 부분을 추가하였다.

.data
Single_Buf__ BYTE ?
Byte_Read__ DWORD ?

.code
xor ecx, ecx
xor edi, edi
Read_Loop:
	push eax
	push ecx
	push edx
	INVOKE ReadFile, eax, offset Single_Buf__, 1, offset Byte_Read__, 0
	pop edx
	pop ecx
	pop eax
	cmp DWORD PTR Byte_Read__, 0
	je Read_End
	mov bl, Single_Buf__
	
	cmp bl, 30h	
	;	30h보다 크거나 같고 39h보다 작거나 같으면 숫자를 의미한다. 밑에 10줄은 숫자의 갯수를 읽어 추후 edi가 0이면 출력을 종료하기 위해 설정.
	jge check_int
	jmp not_int
	check_int:
		cmp bl, 39h
		jle int__
		jmp Not_Int
	Int__:
		add edi, 1
		jmp Buffer_Copy

	Not_Int:
		cmp bl, CR
			je Read_Loop
		cmp bl, LF
			je Read_End
	Buffer_Copy:	;	입력 버퍼에 한 개의 문자를 저장
		mov [edx], bl
		inc edx
		inc ecx
		jmp Read_Loop
Read_End:
	mov BYTE PTR [edx], 0
	ret
Read_a_Line ENDP

StrToInt PROC
;;Input edx : 한 줄 읽었을 때의 문자열
;;		esi : 정수 리스트의 처음을 가리킴
;;Output ebx : 한 줄을 읽었을 때, 그 안에 있는 숫자의 개수
;;Function
;;	한 줄의 문자열을 읽으면서 공백으로 구분되는 각 숫자를 리스트에 차례대로 삽입

.code

	xor ebx, ebx	;	ebx는 한 줄을 읽었을 때 나타나는 숫자의 개수이다. 예를 들어, 3 -9 -0015가 입력된다면 이 함수가 ret될 때 3이다.
	xor ecx, ecx	;	ecx는 한 줄을 읽을 때 한 개의 숫자를 읽기 위해 공백을 포함하여 숫자까지 포함된 문자의 개수이다.
					;	예를 들면, 3   -15 인 문자열이 있다면 -15를 읽을 때 최종 setting되는 ecx는 공백3+문자3(-15) = 6이 된다.
	
	To_IntList:
		cmp BYTE PTR [edx], 0	;	문자열의 마지막이면 종료
		je Exit_Func

		cmp BYTE PTR [edx], 20h	;	현재 가리키는 문자가 공백이면 new_str_start로 이동
		je New_Str_Start

		jmp In_String			;	공백이 아니면 숫자/'-'를 가리키므로 string안에 있다는 의미로 in_string으로 이동

		New_Str_Start:
			inc edx		;	다음 문자를 가리키게끔 edx 1 증가
			inc ecx		;	ecx는 한 개의 숫자 문자열을 숫자로 읽기 위해 세팅되며, 한 줄 안에 있는 숫자 문자열의 문자 길이를 나타냄.
			cmp BYTE PTR [edx], 20h	;	다음 문자도 공백이면 다시 new_str_statrt로
			je New_Str_Start
			jmp To_IntList			;	다음 문자가 공백이 아니면 처음으로

		In_String:
			inc edx	;	이미 현재 가리키고 있는 곳은 숫자/'-'이므로 edx 1 증가
			inc ecx	;	문자의 길이를 나타내는 ecx도 1 증가
			cmp BYTE PTR [edx], 20h
			je register_list		;	다음 가리키는 곳이 공백이면 해당 문자열(숫자를 가리키는)을 숫자로 바꾸어 IntList에 등록
			cmp byte ptr [edx], 0
			je register_list		;	마찬가지로 다음 가리키는 곳이 null이어도 IntList에 등록
			jmp In_string			;	공백/'-'가 아니면 아직 숫자를 가리키는 문자열을 계속 탐색

		register_list:
			inc ebx		;	ebx는 .txt파일 한 줄에 들어있는 숫자의 갯수이다. 따라서 IntList에 등록할 때 하나씩 증가시켜야 한다.
			push edx	;	ParseInteger32를 호출할 때 edx를 바꾸어야 하기 때문에 보존
			sub edx, ecx;	edx가 가리키고 있는 곳은 한 개의 숫자의 끝 바로 다음이다. 따라서 ecx만큼 빼주어야 문자열의 처음을 가리킨다.
			call ParseInteger32	;	eax에는 해당 문자열이 가리키는 숫자가 저장
			mov DWORD PTR [esi], eax	;	
			add esi, TYPE DWORD	;	리스트에 등록했으므로 다음 칸에 저장을 위해 TYPE DWORD (4 bytes) 증가
			xor ecx, ecx	;	ecx(숫자를 나타내는 문자열의 길이) 초기화
			pop edx	;	보존했던 edx pop
			jmp To_IntList	;	종료되기 전(문자열의 마지막)까지 루프

Exit_Func:
	ret
StrToInt ENDP

IntToStr PROC
;;Convert an integer to a integer string
;;Input
;;	eax	: integer to convert(32bit signed)
;;	edx : string buffer offset
;;Output
;; integer string in the buffer (EOS('\0'(==0) appended))
;;	ecx : the string size (excluding 0)
;;	example : 123 -> "1230" (ecx=3), -123 -> "-1230" (ecx=4)
push eax
push ebx
push edx
push esi
push edi
;;	esi : will store the original integer value(
;;		 because eax is modified during division)
;; edi : locates buffer offset (initially edx)
mov esi, eax
mov edi, edx

;;If eax is negative, make it positive
test eax, 80000000h
jz P1
	neg eax
P1:
;; int to str conversion (save each char to stack)
;; example : 123 -> push '3', '2', '1' (by division by 10)

	xor ecx, ecx	;	ecx=counter(init to 0)
	mov ebx, 10		;	ebx=radix(10)
ConvLoop:
	cdq				;	sign extension to edx:eax
	div ebx			;	q:eax, r=edx
	or dx, 0030h	;	convert the remainder to ASCII
	push dx			;	push for later reversal
	inc ecx			;	++(character count)
	cmp eax, 0		;	check if quotient == 0
	jnz ConvLoop	;	if not zero, repeat with the quotient

	mov ebx, ecx	;	save ecx(= # of effective digit chars)
	;;add '-' if negative
	test esi, 80000000h	;	esi=original eax
	jz P2
		mov BYTE PTR [edi], '-'	;	add negative sign
		inc edi					;	++(buffer offset)
		inc ebx					;	++(str size)
	P2:
	;;	Stores the chars in the stack in the correct order
	RevLoop:
		pop ax
		mov [edi], al	;	reverse digit string
		inc edi
		loop RevLoop
	mov BYTE PTR [edi], 0	;	attach EOS

	mov ecx, ebx	;	save the str size in ecx
	pop edi
	pop esi
	pop edx
	pop ebx
	pop eax
	ret
IntToStr ENDP

CalculateMinimum PROC
;;Input : eax = testcase의 개수
;;Testcase의 개수의 범위는 따로 지정되지 않았으므로 리스트에 넣고 출력하는 것이 아니라 한 번 계산되면 바로 출력하게끔 함수를 설계
;;Output : 없음.
.data?
	temp DWORD ?	
	temp2 DWORD ?

.data
	temp_min DWORD -1

.code
pushad

mov ecx, eax	;	첫 줄에 쓰여진 정수를 테스트 케이스를 받는 루프 횟수로 할당
TEST_CASES:
	push ecx
	mov eax, stdinHandle
	mov edx, OFFSET inBuf
	call Read_a_Line
	sub edx, ecx
	mov esi, OFFSET IntList
	call StrToInt
	;;StrToInt를 시행하면 ebx는 방금 읽은 문자열에서 정수의 개수를 담고있다.
	sub ebx, 1
	mov temp, ebx	;	ebx에서 1뺀 값을 temp에 담는다. (수행 과제 개수)

	mov eax, stdinHandle
	mov edx, OFFSET inBuf
	call Read_a_Line
	sub edx, ecx
	mov esi, OFFSET IntList2
	call StrToInt
	;;StrToInt를 시행하면 ebx는 방금 읽은 문자열에서 정수의 개수를 담고있다.
	sub ebx, 1
	mov temp2, ebx	;	ebx에서 1뺀 값을 temp2에 담는다. (수행 가능 일수)

	xor eax, eax
	mov ecx, temp	;	수행 과제 개수만큼 Loop를 돈다.
	Each_Task:
		push ecx
		mov ebx, [IntList + ecx*TYPE IntList]	;	가장 마지막 과제부터 처음 과제까지 탐색한다.
		mov temp_min, -1	;	임시적으로, 각 과제에 대해 가장 적게 걸리는 시간을 -1로 초기화한다.

		mov esi, OFFSET IntList2
		add esi, TYPE IntList2	;	esi는 첫 수행일에 일할 수 있는 시간을 담고있다.
		mov ecx, temp2	
		Conducting_Days:
			push ecx
			
			mov edx, DWORD PTR [esi]	;	edx에는, 각 수행일에 일할 수 있는 시간을 할당
			cmp ebx, edx	;	ebx에는 각 과제에 대해 수행을 필요로 하는 시간이 나옴. 
			jg keep_going	;	둘이 비교하여 그 날에 할 수 없으면 keep_going

			cmp temp_min, -1	;	위 비교문을 통과했다는 것은 과제를 수행할 수 있다는 것인데, 이때 등록된 최소 시간이 있는지 판단
			jne Already_min		;	최소시간이 등록되어 있다면 Already_min으로 이동
			mov temp_min, edx	;	해당 일에 과제를 수행할 수 있을 때, 그 과제를 수행할 수 있는 날짜가 등록이 한 번도 안되었을 때
				

			Already_Min:
				;한 번은 이미 과제를 수행할 수 있는 날짜가 존재할 때
				cmp edx, temp_min	;	temp_min과 edx를 비교하여 등록되어 있는 최소 시간이 더 작다면 keep_going
				jg keep_going
				
			mov temp_min, edx	;	등록되어 있는 최소 시간보다 더 작은 값이 들어오면 edx를 temp_min으로 할당

			mov edi, esi	;	지금 esi는 현재까지의 최소 수행 시간을 가리키는 IntList2의 포인터를 가리킨다. 이를 edi로 옮겨 나중에 처리.

			keep_going:
				add esi, TYPE IntList2	;	계속해서 탐색하기 위해 esi에 TYPE IntList2를 더해줌
				pop ecx
			loop Conducting_Days
				
		cmp temp_min, -1	
		je EXIT_TEMP	;	모든 수행일을 탐색하고 최소 수행 시간이 등록되지 않았다면 해당 케이스에 대한 연산을 종료
			
		push ebx		;	수행 시간이 등록되어 있을 때!
		mov ebx, DWORD PTR [edi]
		add eax, ebx	;	edi는 최소 수행 시간을 담고 있는 포인터이므로 이 값을 eax에 더함.
		pop ebx
		mov DWORD PTR [edi], 0	;	최소 수행 시간을 담고 있는 포인터에 있는 값은 이미 사용되었으므로 0으로 초기화
		pop ecx
		loop Each_Task

		NORMAL:
			mov edx, OFFSET StrBuf
			call IntToStr
			pushad
			INVOKE WriteFile, stdoutHandle, edx, ecx, 0, 0
			;;	정상적으로 최소 수행시간이 모두 더해졌다면 IntToStr함수를 통해 문자열로 바꾸고 출력
			popad
			jmp NORMAL_GOING

		EXIT_TEMP:
			;;특정 케이스에서 어떤 한 과제에 대해 수행할 수 있는 날이 없을 때 진행하는 LABEL이다.
			;;pop ecx를 하는 이유는 loop중간에 점프했기 때문에 ecx를 보존하기 위해서이다.
			pop ecx	
			pushad
			INVOKE WriteFile, stdoutHandle, OFFSET EXIT_TEM, 2, 0, 0 ;	'-1'을 출력
			popad

		NORMAL_GOING:
			mov edx, OFFSET new_line
			pushad
			INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0	;	new_line출력
			popad
			pop ecx
	dec ecx		;	단순 loop를 사용하면 "too far" 오류 메시지가 나와 dec와 jnz를 이용하였습니다.
	jnz TEST_CASES

	popad
	ret
CalculateMinimum ENDP

main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax
	
	mov eax, stdinHandle
	mov edx, OFFSET inBuf
 	call Read_a_Line
	sub edx, ecx
	call ParseInteger32
	;	위 5줄은 첫 줄을 읽어서 정수로 반환한 후(테스트 케이스의 개수) 그 값을 eax에 담아냄

	call CalculateMinimum
	;;CalcuateMinimum 함수는 각 테스트 케이스에 대한 연산을 종료하면 바로 출력하는 함수이다.
	exit
main ENDP
END main