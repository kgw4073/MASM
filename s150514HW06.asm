TITLE SQUARE
;프로그램 작성자 : (단독) 20150514 김건우
;설명 : 숫자를 입력받아 제곱을 하고 홀수이면 음수로, 짝수이면 양수로 출력
;입력 : redirection을 통한 in.txt
;출력 : out.txt (입력받은 파일의 숫자들을 제곱한 후 규칙에 맞게 출력)

INCLUDE Irvine32.inc
.STACK 4096

CR=0Dh
LF=0Ah
MAX_SIZE=1024
MAX_NUM_STR=13
MAX_INT_LIST=46
.data
new_line BYTE 0Dh, 0Ah, 0
space BYTE " "	;	숫자 중간에 공백을 출력하기 위함.

.data?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE MAX_SIZE DUP(?)	;	파일의 한 줄을 읽기 위한 버퍼
IntList DWORD MAX_INT_LIST DUP(?)	;	정수의 제곱을 저장하기 위한 리스트
StrBuf BYTE MAX_NUM_STR DUP(?)	;	StrBuf는 IntToStr함수에서 하나의 문자열을 출력하기 위한 버퍼

.code
mov esi, OFFSET IntList	;	esi는 IntList의 주소를 담아, 한 줄을 읽으면서 읽은 숫자를 담는 역할을 할 것

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
;;본인이 직접 설계한 함수
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
			jmp in_string			;	공백/'-'가 아니면 아직 숫자를 가리키는 문자열을 계속 탐색

		register_list:
			inc ebx		;	ebx는 .txt파일 한 줄에 들어있는 숫자의 갯수이다. 따라서 IntList에 등록할 때 하나씩 증가시켜야 한다.
			push edx	;	ParseInteger32를 호출할 때 edx를 바꾸어야 하기 때문에 보존
			sub edx, ecx;	edx가 가리키고 있는 곳은 한 개의 숫자의 끝 바로 다음이다. 따라서 ecx만큼 빼주어야 문자열의 처음을 가리킨다.
			call ParseInteger32	;	eax에는 해당 문자열이 가리키는 숫자가 저장
			imul eax	;	제곱해도 32bit를 넘지 않으므로 imul eax를 통해 자승을 시행
			TEST eax, 1	;	eax의 LSB가 1인지를 판단(홀수/짝수) 
			jz Even_Num	;	ZF가 세팅된다는 것은 짝수를 의미
			neg eax		;	홀수이기 때문에 자승한 값을 음수로 변환
			Even_Num:
				mov DWORD PTR [esi], eax	;	홀수이면 제곱한 값의 -를 취한 값이, 짝수이면 제곱한 값이 EAX에 저장
				add esi, TYPE IntList	;	리스트에 등록했으므로 다음 칸에 저장을 위해 TYPE IntList (4 bytes) 증가
				xor ecx, ecx	;	ecx(숫자를 나타내는 문자열의 길이) 초기화
				pop edx	;	보존했던 edx pop
				jmp To_IntList	;	종료되기 전(문자열의 마지막)까지 루프

Exit_Func:
	ret
StrToInt ENDP

IntToStr PROC
;; 주어진 함수를 그대로 사용하였습니다
push eax
push ebx
push edx
push esi
push edi

mov esi, eax
mov edi, edx

test eax, 80000000h
jz P1
	neg eax
P1:
	xor ecx, ecx
	mov ebx, 10
ConvLoop:
	cdq
	div ebx
	or dx, 0030h
	push dx
	inc ecx
	cmp eax, 0
	jnz ConvLoop

	mov ebx, ecx
	test esi, 80000000h
	jz P2
		mov BYTE PTR [edi], '-'
		inc edi
		inc ebx
	P2:
	RevLoop:
		pop ax
		mov [edi], al
		inc edi
		loop RevLoop
	mov BYTE PTR [edi], 0

	mov ecx, ebx
	pop edi
	pop esi
	pop edx
	pop ebx
	pop eax
	ret
IntToStr ENDP

main PROC
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

	Write_to_out:
		mov eax, stdinHandle
		mov edx, OFFSET inBuf	;	inBuf는 한 줄을 읽기 위한 입력버퍼(Read_a_Line)
		
		call Read_a_Line	;	edx에 한 줄을 읽은 문자열을 저장
		cmp edi, 0			;	숫자가 하나도 없으면(edi==0) 프로그램을 종료
		je Exit_Prog

		sub edx, ecx	;	이 연산을 통해 edx는 읽은 문자열의 처음을 가리킨다.
		mov esi, OFFSET IntList	;	새로운 줄을 읽기 위해 esi를 IntList의 처음 주소로 세팅
		call StrToInt	;	StrToInt를 실행한 후 ebx는 한 줄을 읽었을 때의 숫자 개수
		mov ecx, ebx	;	루프를 ebx번 만큼 돌며 파일에 차례로 출력한다.
		mov esi, OFFSET IntList	;	세 줄 위의 코드와 다름. 본 행은 정수 리스트를 출력하기 위해 esi를 IntList의 처음 주소로 세팅

		Print_one_line:
			mov eax, DWORD PTR [esi]	;	[esi]는 정수 리스트의 원소를 나타냄, 
			mov edx, OFFSET StrBuf	;	출력을 위한 문자열 버퍼
			;;IntToStr은 input으로 eax : 출력하고자 하는 정수, edx : 출력 버퍼 주소를 요구한다.
			push ecx		;	현재 ecx를 보존(IntToStr에서 ecx가 바뀌기 때문)

			call IntToStr	
			;	IntToStr을 실행하고 난 후, edx에는 음수면 -가 붙여져서, 양수면 그대로인 문자열이 생성된다.
			;	ecx는 문자열의 길이를 나타낸다.

			pushad
			INVOKE WriteFile, stdoutHandle, edx, ecx, 0, 0	;	파일에 해당 문자열을 출력
			popad
			pop ecx			;	보존한 ecx를 pop

			cmp ecx, 1		
			je Last_Number		;	문자열의 마지막 숫자면 공백을 출력 안하고 점프하여 new_line 출력

			mov edx, OFFSET space	;	문자열의 마지막 숫자가 아니면 숫자를 출력하고 난 후에 공백을 출력
			pushad
			INVOKE WriteFile, stdoutHandle, edx, 1, 0, 0
			popad
			add esi, TYPE IntList	;	정수 리스트 중 하나를 읽었으므로 4bytes만큼 증가
			loop Print_one_line

			Last_Number:	;	마지막 숫자이면 줄바꿈을 출력
				mov edx, OFFSET new_line
				INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0
				jmp Write_to_out
				
		Exit_Prog:
			Exit
main ENDP
END main