TITLE MINIMUM_LABOR
;���α׷� �ۼ��� : (�ܵ�) 20150514 ��ǿ�
;���� : �־��� ���Ͽ� ���� �� �׽�Ʈ ���̽��� ���� MINIMUM_LABOR_TIME�� ����Ͽ� ����Ѵ�. ������ �� ���ٸ� -1�� ����Ѵ�.
;		ù ��° �ٿ� �������� �ҿ�ð��� �־����� �� ��° �ٿ��� ���� ���� �����ϸ��� ������ ������ �� �ִ� �ð��� �־�����.
;		�־��� ������ ���� �� ���� ������ �� ���ٸ� -1�� ����ϰ� ��� ������ �� �ִٸ� �ҿ� �ð��� �ּҸ� ����Ѵ�.
;		�ش� ���α׷��� ������ �� �� �������� Min Labor Time�� ã�Ƽ� Greedy Method�� �̿��Ͽ���.

;�Է� : redirection�� ���� in.txt
;��� : out.txt

INCLUDE Irvine32.inc
.STACK 4096

CR=0Dh
LF=0Ah
MAX_SIZE=100	;	�� �ٿ� �ִ� 100�� ������ ���ڰ� ���� �� �ִ�. (������ '31 24 24 24 .. �� ���� �� 3���� ���ڰ� 32�� �ݺ�= �ִ� 96���� ����)
MAX_NUM_STR=4	;	24�� �ִ� 31�� �ݺ��Ǿ� �ִ� 744�� ��µ� �� �ִ�. �׷��� ������ ���ڿ��� ũ�⸦ 4�� ���Ͽ���.
MAX_INT_LIST=32	;	�ִ� TASK�� ������ 31�̸� ���� �տ� ������ ��Ÿ���� ���ڱ��� �ִ� 32���� ������ �޾ƾ� �Ѵ�.
.data
new_line BYTE 0Dh, 0Ah, 0
space BYTE " "	;	���� �߰��� ������ ����ϱ� ����.

EXIT_TEM BYTE "-1"

.data?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE MAX_SIZE DUP(?)	;	������ �� ���� �б� ���� ����

IntList DWORD MAX_INT_LIST DUP(?)	;	ù ��° ��, ��, �������� �ɸ��� �ð��� ���� ��������Ʈ
IntList2 DWORD MAX_INT_LIST DUP(?)	;	�� ��° ��, ��, ���� �����ϸ��� ������ �� �ִ� �ð��� ���� ��������Ʈ

StrBuf BYTE MAX_NUM_STR DUP(?)	;	StrBuf�� IntToStr�Լ����� �ϳ��� ���ڿ��� ����ϱ� ���� ����


.code

Read_a_Line PROC	
; Read_a_Line �Լ����� edi reg�� ���� ���ڿ� �ش��ϴ� ���ڸ� ���� �κ��� �߰��Ͽ���.

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
	;	30h���� ũ�ų� ���� 39h���� �۰ų� ������ ���ڸ� �ǹ��Ѵ�. �ؿ� 10���� ������ ������ �о� ���� edi�� 0�̸� ����� �����ϱ� ���� ����.
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
	Buffer_Copy:	;	�Է� ���ۿ� �� ���� ���ڸ� ����
		mov [edx], bl
		inc edx
		inc ecx
		jmp Read_Loop
Read_End:
	mov BYTE PTR [edx], 0
	ret
Read_a_Line ENDP

StrToInt PROC
;;Input edx : �� �� �о��� ���� ���ڿ�
;;		esi : ���� ����Ʈ�� ó���� ����Ŵ
;;Output ebx : �� ���� �о��� ��, �� �ȿ� �ִ� ������ ����
;;Function
;;	�� ���� ���ڿ��� �����鼭 �������� ���еǴ� �� ���ڸ� ����Ʈ�� ���ʴ�� ����

.code

	xor ebx, ebx	;	ebx�� �� ���� �о��� �� ��Ÿ���� ������ �����̴�. ���� ���, 3 -9 -0015�� �Էµȴٸ� �� �Լ��� ret�� �� 3�̴�.
	xor ecx, ecx	;	ecx�� �� ���� ���� �� �� ���� ���ڸ� �б� ���� ������ �����Ͽ� ���ڱ��� ���Ե� ������ �����̴�.
					;	���� ���, 3   -15 �� ���ڿ��� �ִٸ� -15�� ���� �� ���� setting�Ǵ� ecx�� ����3+����3(-15) = 6�� �ȴ�.
	
	To_IntList:
		cmp BYTE PTR [edx], 0	;	���ڿ��� �������̸� ����
		je Exit_Func

		cmp BYTE PTR [edx], 20h	;	���� ����Ű�� ���ڰ� �����̸� new_str_start�� �̵�
		je New_Str_Start

		jmp In_String			;	������ �ƴϸ� ����/'-'�� ����Ű�Ƿ� string�ȿ� �ִٴ� �ǹ̷� in_string���� �̵�

		New_Str_Start:
			inc edx		;	���� ���ڸ� ����Ű�Բ� edx 1 ����
			inc ecx		;	ecx�� �� ���� ���� ���ڿ��� ���ڷ� �б� ���� ���õǸ�, �� �� �ȿ� �ִ� ���� ���ڿ��� ���� ���̸� ��Ÿ��.
			cmp BYTE PTR [edx], 20h	;	���� ���ڵ� �����̸� �ٽ� new_str_statrt��
			je New_Str_Start
			jmp To_IntList			;	���� ���ڰ� ������ �ƴϸ� ó������

		In_String:
			inc edx	;	�̹� ���� ����Ű�� �ִ� ���� ����/'-'�̹Ƿ� edx 1 ����
			inc ecx	;	������ ���̸� ��Ÿ���� ecx�� 1 ����
			cmp BYTE PTR [edx], 20h
			je register_list		;	���� ����Ű�� ���� �����̸� �ش� ���ڿ�(���ڸ� ����Ű��)�� ���ڷ� �ٲپ� IntList�� ���
			cmp byte ptr [edx], 0
			je register_list		;	���������� ���� ����Ű�� ���� null�̾ IntList�� ���
			jmp In_string			;	����/'-'�� �ƴϸ� ���� ���ڸ� ����Ű�� ���ڿ��� ��� Ž��

		register_list:
			inc ebx		;	ebx�� .txt���� �� �ٿ� ����ִ� ������ �����̴�. ���� IntList�� ����� �� �ϳ��� �������Ѿ� �Ѵ�.
			push edx	;	ParseInteger32�� ȣ���� �� edx�� �ٲپ�� �ϱ� ������ ����
			sub edx, ecx;	edx�� ����Ű�� �ִ� ���� �� ���� ������ �� �ٷ� �����̴�. ���� ecx��ŭ ���־�� ���ڿ��� ó���� ����Ų��.
			call ParseInteger32	;	eax���� �ش� ���ڿ��� ����Ű�� ���ڰ� ����
			mov DWORD PTR [esi], eax	;	
			add esi, TYPE DWORD	;	����Ʈ�� ��������Ƿ� ���� ĭ�� ������ ���� TYPE DWORD (4 bytes) ����
			xor ecx, ecx	;	ecx(���ڸ� ��Ÿ���� ���ڿ��� ����) �ʱ�ȭ
			pop edx	;	�����ߴ� edx pop
			jmp To_IntList	;	����Ǳ� ��(���ڿ��� ������)���� ����

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
;;Input : eax = testcase�� ����
;;Testcase�� ������ ������ ���� �������� �ʾ����Ƿ� ����Ʈ�� �ְ� ����ϴ� ���� �ƴ϶� �� �� ���Ǹ� �ٷ� ����ϰԲ� �Լ��� ����
;;Output : ����.
.data?
	temp DWORD ?	
	temp2 DWORD ?

.data
	temp_min DWORD -1

.code
pushad

mov ecx, eax	;	ù �ٿ� ������ ������ �׽�Ʈ ���̽��� �޴� ���� Ƚ���� �Ҵ�
TEST_CASES:
	push ecx
	mov eax, stdinHandle
	mov edx, OFFSET inBuf
	call Read_a_Line
	sub edx, ecx
	mov esi, OFFSET IntList
	call StrToInt
	;;StrToInt�� �����ϸ� ebx�� ��� ���� ���ڿ����� ������ ������ ����ִ�.
	sub ebx, 1
	mov temp, ebx	;	ebx���� 1�� ���� temp�� ��´�. (���� ���� ����)

	mov eax, stdinHandle
	mov edx, OFFSET inBuf
	call Read_a_Line
	sub edx, ecx
	mov esi, OFFSET IntList2
	call StrToInt
	;;StrToInt�� �����ϸ� ebx�� ��� ���� ���ڿ����� ������ ������ ����ִ�.
	sub ebx, 1
	mov temp2, ebx	;	ebx���� 1�� ���� temp2�� ��´�. (���� ���� �ϼ�)

	xor eax, eax
	mov ecx, temp	;	���� ���� ������ŭ Loop�� ����.
	Each_Task:
		push ecx
		mov ebx, [IntList + ecx*TYPE IntList]	;	���� ������ �������� ó�� �������� Ž���Ѵ�.
		mov temp_min, -1	;	�ӽ�������, �� ������ ���� ���� ���� �ɸ��� �ð��� -1�� �ʱ�ȭ�Ѵ�.

		mov esi, OFFSET IntList2
		add esi, TYPE IntList2	;	esi�� ù �����Ͽ� ���� �� �ִ� �ð��� ����ִ�.
		mov ecx, temp2	
		Conducting_Days:
			push ecx
			
			mov edx, DWORD PTR [esi]	;	edx����, �� �����Ͽ� ���� �� �ִ� �ð��� �Ҵ�
			cmp ebx, edx	;	ebx���� �� ������ ���� ������ �ʿ�� �ϴ� �ð��� ����. 
			jg keep_going	;	���� ���Ͽ� �� ���� �� �� ������ keep_going

			cmp temp_min, -1	;	�� �񱳹��� ����ߴٴ� ���� ������ ������ �� �ִٴ� ���ε�, �̶� ��ϵ� �ּ� �ð��� �ִ��� �Ǵ�
			jne Already_min		;	�ּҽð��� ��ϵǾ� �ִٸ� Already_min���� �̵�
			mov temp_min, edx	;	�ش� �Ͽ� ������ ������ �� ���� ��, �� ������ ������ �� �ִ� ��¥�� ����� �� ���� �ȵǾ��� ��
				

			Already_Min:
				;�� ���� �̹� ������ ������ �� �ִ� ��¥�� ������ ��
				cmp edx, temp_min	;	temp_min�� edx�� ���Ͽ� ��ϵǾ� �ִ� �ּ� �ð��� �� �۴ٸ� keep_going
				jg keep_going
				
			mov temp_min, edx	;	��ϵǾ� �ִ� �ּ� �ð����� �� ���� ���� ������ edx�� temp_min���� �Ҵ�

			mov edi, esi	;	���� esi�� ��������� �ּ� ���� �ð��� ����Ű�� IntList2�� �����͸� ����Ų��. �̸� edi�� �Ű� ���߿� ó��.

			keep_going:
				add esi, TYPE IntList2	;	����ؼ� Ž���ϱ� ���� esi�� TYPE IntList2�� ������
				pop ecx
			loop Conducting_Days
				
		cmp temp_min, -1	
		je EXIT_TEMP	;	��� �������� Ž���ϰ� �ּ� ���� �ð��� ��ϵ��� �ʾҴٸ� �ش� ���̽��� ���� ������ ����
			
		push ebx		;	���� �ð��� ��ϵǾ� ���� ��!
		mov ebx, DWORD PTR [edi]
		add eax, ebx	;	edi�� �ּ� ���� �ð��� ��� �ִ� �������̹Ƿ� �� ���� eax�� ����.
		pop ebx
		mov DWORD PTR [edi], 0	;	�ּ� ���� �ð��� ��� �ִ� �����Ϳ� �ִ� ���� �̹� ���Ǿ����Ƿ� 0���� �ʱ�ȭ
		pop ecx
		loop Each_Task

		NORMAL:
			mov edx, OFFSET StrBuf
			call IntToStr
			pushad
			INVOKE WriteFile, stdoutHandle, edx, ecx, 0, 0
			;;	���������� �ּ� ����ð��� ��� �������ٸ� IntToStr�Լ��� ���� ���ڿ��� �ٲٰ� ���
			popad
			jmp NORMAL_GOING

		EXIT_TEMP:
			;;Ư�� ���̽����� � �� ������ ���� ������ �� �ִ� ���� ���� �� �����ϴ� LABEL�̴�.
			;;pop ecx�� �ϴ� ������ loop�߰��� �����߱� ������ ecx�� �����ϱ� ���ؼ��̴�.
			pop ecx	
			pushad
			INVOKE WriteFile, stdoutHandle, OFFSET EXIT_TEM, 2, 0, 0 ;	'-1'�� ���
			popad

		NORMAL_GOING:
			mov edx, OFFSET new_line
			pushad
			INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0	;	new_line���
			popad
			pop ecx
	dec ecx		;	�ܼ� loop�� ����ϸ� "too far" ���� �޽����� ���� dec�� jnz�� �̿��Ͽ����ϴ�.
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
	;	�� 5���� ù ���� �о ������ ��ȯ�� ��(�׽�Ʈ ���̽��� ����) �� ���� eax�� ��Ƴ�

	call CalculateMinimum
	;;CalcuateMinimum �Լ��� �� �׽�Ʈ ���̽��� ���� ������ �����ϸ� �ٷ� ����ϴ� �Լ��̴�.
	exit
main ENDP
END main