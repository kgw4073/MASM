TITLE SQUARE
;���α׷� �ۼ��� : (�ܵ�) 20150514 ��ǿ�
;���� : ���ڸ� �Է¹޾� ������ �ϰ� Ȧ���̸� ������, ¦���̸� ����� ���
;�Է� : redirection�� ���� in.txt
;��� : out.txt (�Է¹��� ������ ���ڵ��� ������ �� ��Ģ�� �°� ���)

INCLUDE Irvine32.inc
.STACK 4096

CR=0Dh
LF=0Ah
MAX_SIZE=1024
MAX_NUM_STR=13
MAX_INT_LIST=46
.data
new_line BYTE 0Dh, 0Ah, 0
space BYTE " "	;	���� �߰��� ������ ����ϱ� ����.

.data?
stdinHandle HANDLE ?
stdoutHandle HANDLE ?
inBuf BYTE MAX_SIZE DUP(?)	;	������ �� ���� �б� ���� ����
IntList DWORD MAX_INT_LIST DUP(?)	;	������ ������ �����ϱ� ���� ����Ʈ
StrBuf BYTE MAX_NUM_STR DUP(?)	;	StrBuf�� IntToStr�Լ����� �ϳ��� ���ڿ��� ����ϱ� ���� ����

.code
mov esi, OFFSET IntList	;	esi�� IntList�� �ּҸ� ���, �� ���� �����鼭 ���� ���ڸ� ��� ������ �� ��

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
;;������ ���� ������ �Լ�
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
			jmp in_string			;	����/'-'�� �ƴϸ� ���� ���ڸ� ����Ű�� ���ڿ��� ��� Ž��

		register_list:
			inc ebx		;	ebx�� .txt���� �� �ٿ� ����ִ� ������ �����̴�. ���� IntList�� ����� �� �ϳ��� �������Ѿ� �Ѵ�.
			push edx	;	ParseInteger32�� ȣ���� �� edx�� �ٲپ�� �ϱ� ������ ����
			sub edx, ecx;	edx�� ����Ű�� �ִ� ���� �� ���� ������ �� �ٷ� �����̴�. ���� ecx��ŭ ���־�� ���ڿ��� ó���� ����Ų��.
			call ParseInteger32	;	eax���� �ش� ���ڿ��� ����Ű�� ���ڰ� ����
			imul eax	;	�����ص� 32bit�� ���� �����Ƿ� imul eax�� ���� �ڽ��� ����
			TEST eax, 1	;	eax�� LSB�� 1������ �Ǵ�(Ȧ��/¦��) 
			jz Even_Num	;	ZF�� ���õȴٴ� ���� ¦���� �ǹ�
			neg eax		;	Ȧ���̱� ������ �ڽ��� ���� ������ ��ȯ
			Even_Num:
				mov DWORD PTR [esi], eax	;	Ȧ���̸� ������ ���� -�� ���� ����, ¦���̸� ������ ���� EAX�� ����
				add esi, TYPE IntList	;	����Ʈ�� ��������Ƿ� ���� ĭ�� ������ ���� TYPE IntList (4 bytes) ����
				xor ecx, ecx	;	ecx(���ڸ� ��Ÿ���� ���ڿ��� ����) �ʱ�ȭ
				pop edx	;	�����ߴ� edx pop
				jmp To_IntList	;	����Ǳ� ��(���ڿ��� ������)���� ����

Exit_Func:
	ret
StrToInt ENDP

IntToStr PROC
;; �־��� �Լ��� �״�� ����Ͽ����ϴ�
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
		mov edx, OFFSET inBuf	;	inBuf�� �� ���� �б� ���� �Է¹���(Read_a_Line)
		
		call Read_a_Line	;	edx�� �� ���� ���� ���ڿ��� ����
		cmp edi, 0			;	���ڰ� �ϳ��� ������(edi==0) ���α׷��� ����
		je Exit_Prog

		sub edx, ecx	;	�� ������ ���� edx�� ���� ���ڿ��� ó���� ����Ų��.
		mov esi, OFFSET IntList	;	���ο� ���� �б� ���� esi�� IntList�� ó�� �ּҷ� ����
		call StrToInt	;	StrToInt�� ������ �� ebx�� �� ���� �о��� ���� ���� ����
		mov ecx, ebx	;	������ ebx�� ��ŭ ���� ���Ͽ� ���ʷ� ����Ѵ�.
		mov esi, OFFSET IntList	;	�� �� ���� �ڵ�� �ٸ�. �� ���� ���� ����Ʈ�� ����ϱ� ���� esi�� IntList�� ó�� �ּҷ� ����

		Print_one_line:
			mov eax, DWORD PTR [esi]	;	[esi]�� ���� ����Ʈ�� ���Ҹ� ��Ÿ��, 
			mov edx, OFFSET StrBuf	;	����� ���� ���ڿ� ����
			;;IntToStr�� input���� eax : ����ϰ��� �ϴ� ����, edx : ��� ���� �ּҸ� �䱸�Ѵ�.
			push ecx		;	���� ecx�� ����(IntToStr���� ecx�� �ٲ�� ����)

			call IntToStr	
			;	IntToStr�� �����ϰ� �� ��, edx���� ������ -�� �ٿ�����, ����� �״���� ���ڿ��� �����ȴ�.
			;	ecx�� ���ڿ��� ���̸� ��Ÿ����.

			pushad
			INVOKE WriteFile, stdoutHandle, edx, ecx, 0, 0	;	���Ͽ� �ش� ���ڿ��� ���
			popad
			pop ecx			;	������ ecx�� pop

			cmp ecx, 1		
			je Last_Number		;	���ڿ��� ������ ���ڸ� ������ ��� ���ϰ� �����Ͽ� new_line ���

			mov edx, OFFSET space	;	���ڿ��� ������ ���ڰ� �ƴϸ� ���ڸ� ����ϰ� �� �Ŀ� ������ ���
			pushad
			INVOKE WriteFile, stdoutHandle, edx, 1, 0, 0
			popad
			add esi, TYPE IntList	;	���� ����Ʈ �� �ϳ��� �о����Ƿ� 4bytes��ŭ ����
			loop Print_one_line

			Last_Number:	;	������ �����̸� �ٹٲ��� ���
				mov edx, OFFSET new_line
				INVOKE WriteFile, stdoutHandle, edx, 2, 0, 0
				jmp Write_to_out
				
		Exit_Prog:
			Exit
main ENDP
END main