TITLE Polynomial
;	���α׷� �ۼ��� : 20150514 ��ǿ�
;	��� : �־��� ���׽� 38*x1 + 47*x2 + 19*x3�� ����ϱ� ���� ���α׷�
;	�Է� : CSE3030_PHW02_2019.inc�� ������ ���Ϸ� �����Ѵ�. ���� �ȳ����� ���ÿ� ������ x1=5, x2=-10, x3=20���� ���� DWORD�� �����.
;	��� : ���� ��� ���� ���׽Ŀ� ���� �����͸� �Է��ϸ� +100�� ���;� ��.

INCLUDE Irvine32.inc
;	Irvine32 ���̺귯���� ���Խ�Ų��.

INCLUDE CSE3030_PHW02_2019.inc
COMMENT @
���̺귯�� �Ӽ��� ���� �� C:\Irvine���� ��θ� �������Ƿ� �ش� ��ο� ������ ������ �����Ų��.
@

.code
main PROC
	mov eax, 0
	add eax, x1	
	add eax, x2	
	add eax, x3		; eax = x1+x2+x3
	mov ebx, eax	; ebx = x1+x2+x3	ebx�� x1+x2+x3�� ��� ����
	add eax, eax	; eax = 2*(x1+x2+x3)
	add eax, eax	; eax = 4*(x1+x2+x3)
	add eax, eax	; eax = 8*(x1+x2+x3)
	add eax, eax	; eax = 16*(x1+x2+x3)
	add eax, ebx	; eax = 17*(x1+x2+x3)
	add eax, ebx	; eax = 18*(x1+x2+x3)
	add eax, ebx	; eax = 19*(x1+x2+x3)
	add eax, eax	; eax = 38*(x1+x2+x3)
	mov ebx, eax	; ebx = 38*(x1+x2+x3)
	mov eax, x2		; eax = x2
	sub eax, x3		; eax = x2 - x3
	sub eax, x3		; eax = x2 - 2*x3
	mov edx, eax	; edx = x2 - 2*x3	edx���ٰ� x2 - 2*x3�� ��� ����
	add eax, eax	; eax = 2*x2 - 4*x3
	add eax, eax	; eax = 4*x2 - 8*x3
	add eax, eax	; eax = 8*x2 - 16*x3
	add eax, edx	; eax = 9*x2 - 18*x3
	sub eax, x3		; eax = 9*x2 - 19*x3
	add eax, ebx	; eax = 38*(x1+x2+x3) + 9*x2 - 19*x3
	call WriteInt	; eax�� ���������� ����� �������� ���
	exit
main ENDP
END main