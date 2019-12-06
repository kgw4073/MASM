TITLE Redirection	;
;	프로그램 작성자 : 20150514 김건우
;	설명 : 각 행에 저장된 문자를 앞에 있는 숫자만큼 반복하는 프로그램
;	입력 : in.txt(반복할 횟수와 문자열이 들어있는 파일)
;	출력 : out.txt(각각의 문자가 반복되어 저장된 파일)

INCLUDE Irvine32.inc

.stack 4096	; 이후 스택을 사용할 것이므로 크기를 정함

CR=0Dh	;	new_line
LF=0Ah

BUF_SIZE=20	;	null을 제외하고 최대 20개의 문자를 읽을 수 있으므로 
.data
	stdinHandle HANDLE ?
	stdoutHandle HANDLE ?
	inBuf BYTE BUF_SIZE DUP(?)
	bytesREAD DWORD ?
	outBuf BYTE BUF_SIZE DUP(?)
	bytesWRITE DWORD ?
	new_line BYTE 0Dh, 0Ah, 0	;	new_line 문자열
	temp DWORD ?	;	temp와 temp_2는 모두 ecx를 저장하기 위한 메모리
	temp_2 DWORD ?

.code

Read_a_Line PROC	
; Read_a_Line 함수는 참고자료 그대로 사용
.data
Single_Buf__ BYTE ?
Byte_Read__ DWORD ?

.code
xor ecx, ecx
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
	cmp bl, CR
		je Read_Loop
	cmp bl, LF
		je Read_End
	mov [edx], bl
	inc edx
	inc ecx
	jmp Read_Loop
Read_End:
	mov BYTE PTR [edx], 0
	ret
Read_a_Line ENDP

main PROC
	; 다음 네 줄은 HANDLE을 저장하기 위함
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdinHandle, eax
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov stdoutHandle, eax

	
	Write_to_out:
		; Write_to_out은 out.txt에 저장하기 위한 블록

		mov eax, stdinHandle
		mov edx, OFFSET inBuf	; Read_a_Line은 input으로 eax에 HANDLE, edx에 읽을 문자열을 저장할 OFFSET이 필요하다.
		INVOKE Read_a_Line
		
		cmp ecx, 2
		jle Exit_P	;	읽은 문자의 갯수가 2개 이하이면 종료한다.

		sub edx, ecx	; Read_a_Line을 실행한 후 edx는 문자열의 끝을 가리키게 된다. 따라서 문자열의 시작으로 가기 위해서 읽은 문자 수 만큼 빼준다.
		mov ebx, 0
		mov bl, [edx]	; ebx에 문자열의 처음, 즉, 숫자를 나타내는 문자를 저장한다.
		sub ebx, 30h	; 아스키문자로 나타낸 값을 진짜 숫자로 바꾸기 위해 30h를 빼준다.
		mov temp, ebx	; ebx에는 각 행의 처음 나타나는 숫자가 저장된다. 이를 temp에 저장한다.

		sub ecx, 2	; 읽은 문자의 갯수 중 첫 두 문자는 의미가 없다.(숫자와 공백) 따라서 2를 빼준다.
		add edx, 2	; 반복할 문자열 또한 두 번째 뒤이므로 edx에 2를 더해준다.

		cmp ebx, 1	; ebx가 1보다 작거나, 9보다 크면, (즉, 숫자가 아니면) 종료한다.
		jl Exit_P
		cmp ebx, 9
		jg Exit_P

		NEXT_LINE:
			;	NEXT_LINE은 파일의 한 행을 돌게 되는 루프이다.
			push ecx	; 첫 번째 루프의 ecx를 보존하기 위해 ecx를 push
			mov ecx, temp	;	temp에는 위에서 저장한 각 행의 첫 번째 숫자가 저장되어 있다.

			Each_Character:	; 두 번째 루프를 돌며 각 문자에 대해 temp번만큼 반복한다.
				pushad 	; pushad를 한 이유는 WriteFile을 하며 레지스터의 값이 바뀌기 때문에 그 값을 보존하기 위해 스택을 이용하였다.
				INVOKE WriteFile, stdoutHandle, edx, 1, 0, 0
				popad
				loop Each_Character

			add edx, 1	; edx가 다음 문자를 가리키게 하기 위해 1을 더해줌.
			pop ecx	; 보존했던 첫 번째 루프의 ecx를 pop한다.
			loop NEXT_LINE
		
		;	다음 세 줄은 한 행의 출력을 끝냈기 때문에 다음 라인에 나타내기 위해 new_line을 출력하는 코드이다. 다시 Write_to_out 블록을 돌며 더 이상의 문자가 없을 때까지 반복한다.
		mov edx, OFFSET new_line	
		INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0
		jmp Write_to_out
		
	Exit_P:
		exit
main ENDP
END MAIN