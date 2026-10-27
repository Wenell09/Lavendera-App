import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/order/presentation/bloc/order_bloc.dart';

import '../../domain/entities/order_entity.dart';
import '../bloc/action/order_action_bloc.dart';
import '../bloc/detail/order_detail_bloc.dart';
import '../widgets/cash_payment_dialog.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline_widget.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<OrderDetailBloc>()..add(GetOrderDetailRequest(id: orderId)),
      child: _OrderDetailView(orderId: orderId),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final String orderId;

  const _OrderDetailView({required this.orderId});

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$minute';
  }

  void _confirmCancelOrder(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text(
              'Batalkan Order?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan order ${order.orderNumber}? Tindakan ini tidak dapat diurungkan.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Kembali',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<OrderActionBloc>().add(
                CancelOrderActionRequest(id: order.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPaymentModal(BuildContext context, OrderEntity order) {
    if (order.payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informasi payment tidak tersedia',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          dismissDirection: .horizontal,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Konfirmasi bahwa pembayaran untuk order ${order.orderNumber} sejumlah ${CurrencyFormatter.format(order.totalAmount)} telah lunas diterima?',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<OrderActionBloc>().add(
                ConfirmPaymentActionRequest(
                  orderId: order.id,
                  paymentId: order.payment!.id,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Konfirmasi Lunas',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCashPaymentModal(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (_) => CashPaymentDialog(
        totalAmount: order.totalAmount,
        onSubmit: (paidAmount) {
          context.read<OrderActionBloc>().add(
            InputCashPaymentActionRequest(
              orderId: order.id,
              paidAmount: paidAmount,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderActionBloc, OrderActionState>(
      listener: (context, actionState) {
        if (actionState is OrderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                actionState.message,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              dismissDirection: .horizontal,
            ),
          );
          // Reload detail
          context.read<OrderDetailBloc>().add(
            GetOrderDetailRequest(id: orderId),
          );
          // reload list
          context.read<OrderBloc>().add(GetOrdersRequest());
        } else if (actionState is OrderActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                actionState.message,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              dismissDirection: .horizontal,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Detail Pesanan',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4A99AD)),
              onPressed: () {
                context.read<OrderDetailBloc>().add(
                  GetOrderDetailRequest(id: orderId),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A99AD)),
              );
            }
            if (state is OrderDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OrderDetailBloc>().add(
                            GetOrderDetailRequest(id: orderId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A99AD),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is OrderDetailLoaded) {
              final order = state.order;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Order Header Card
                        _buildHeaderCard(context, order),
                        const SizedBox(height: 14),

                        // Timeline Status
                        OrderTimelineWidget(currentStatus: order.status),
                        const SizedBox(height: 14),

                        // Tracking Token Card (jika tersedia)
                        if (order.trackingToken != null &&
                            order.trackingToken!.isNotEmpty) ...[
                          _buildTrackingTokenCard(
                            context,
                            order.trackingToken!,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Customer & Outlet Info Card
                        _buildPartyInfoCard(order),
                        const SizedBox(height: 14),

                        // Items Breakdown Card
                        _buildItemsCard(order),
                        const SizedBox(height: 14),

                        // Payment & Billing Summary Card
                        _buildBillingCard(order),
                        const SizedBox(height: 14),

                        // Notes & Metadata Card
                        _buildMetadataCard(order),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  _buildBottomActionBar(context, order),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Pesanan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                'Dibuat: ${_formatDateTime(order.createdAt)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTokenCard(BuildContext context, String token) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A99AD).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4A99AD).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF4A99AD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Token Lacak Pelanggan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF334155),
                  ),
                ),
                Text(
                  token,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              color: Color(0xFF4A99AD),
              size: 20,
            ),
            tooltip: 'Salin Token',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Token pelacakan berhasil disalin',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: .horizontal,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartyInfoCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pelanggan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      order.customer.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (order.customer.phone != null &&
                        order.customer.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.customer.phone!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (order.customer.address != null &&
                        order.customer.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.customer.address!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          // Outlet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.store_rounded,
                  color: Colors.teal.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outlet Cabang',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      order.outlet.name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (order.outlet.address != null &&
                        order.outlet.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.outlet.address!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Layanan Dipilih',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${order.items.length} item',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, _) => const Divider(
              height: 16,
              thickness: 0.7,
              color: Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A99AD).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_laundry_service_rounded,
                        color: Color(0xFF4A99AD),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.service.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.quantity} ${item.unit} × ${CurrencyFormatter.format(item.price)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.subtotal),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              OrderStatusBadge(status: order.paymentStatus, isPayment: true),
            ],
          ),
          const SizedBox(height: 14),
          _buildBillRow('Subtotal', CurrencyFormatter.format(order.subtotal)),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Diskon ${order.discount != null ? "(${order.discount!.name})" : ""}',
              '- ${CurrencyFormatter.format(order.discountAmount)}',
              isGreen: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildBillRow(
            'Total Tagihan',
            CurrencyFormatter.format(order.totalAmount),
            isBold: true,
            fontSize: 15,
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Uang Diterima',
            CurrencyFormatter.format(order.paidAmount),
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Kembalian',
            CurrencyFormatter.format(order.changeAmount),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildBillRow(
            'Metode Pembayaran',
            (order.payment?.paymentMethod ?? 'CASH').toUpperCase(),
          ),
          if (order.payment?.paidAt != null) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Waktu Lunas',
              _formatDateTime(order.payment!.paidAt),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isBold = false,
    bool isGreen = false,
    double fontSize = 13,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isGreen
                ? const Color(0xFF16A34A)
                : isBold
                ? const Color(0xFF0F172A)
                : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const Text(
              'Catatan Khusus:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                order.notes!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (order.estimatedDone != null)
            _buildBillRow(
              'Estimasi Selesai',
              _formatDateTime(order.estimatedDone),
            ),
          if (order.completedAt != null) ...[
            const SizedBox(height: 6),
            _buildBillRow('Waktu Selesai', _formatDateTime(order.completedAt)),
          ],
          if (order.canceledAt != null) ...[
            const SizedBox(height: 6),
            _buildBillRow(
              'Waktu Dibatalkan',
              _formatDateTime(order.canceledAt),
            ),
          ],
          if (order.creator != null) ...[
            const SizedBox(height: 6),
            _buildBillRow('Dibuat oleh', order.creator!.name),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, OrderEntity order) {
    final status = order.status.toUpperCase();
    final paymentStatus = order.paymentStatus.toUpperCase();
    final isCash = (order.payment?.paymentMethod ?? '').toLowerCase() == 'cash';
    final isUnpaid = paymentStatus != 'PAID';

    // Jika order sudah dibatalkan atau sudah diambil dan lunas, tidak butuh action bar
    if (status == 'DIBATALKAN' || (status == 'DIAMBIL' && !isUnpaid)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Transitions Buttons
            if (status == 'MENUNGGU_KONFIRMASI') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmCancelOrder(context, order),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batalkan Order',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<OrderActionBloc>().add(
                          UpdateOrderStatusActionRequest(
                            id: order.id,
                            status: 'DIPROSES',
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Proses Sekarang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A99AD),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'DIPROSES') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<OrderActionBloc>().add(
                      UpdateOrderStatusActionRequest(
                        id: order.id,
                        status: 'SELESAI',
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tandai Pesanan Selesai',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else if (status == 'SELESAI') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<OrderActionBloc>().add(
                      UpdateOrderStatusActionRequest(
                        id: order.id,
                        status: 'DIAMBIL',
                      ),
                    );
                  },
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  label: const Text(
                    'Pesanan Sudah Diambil Customer',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Payment Action if Unpaid
            if (isUnpaid) ...[
              const SizedBox(height: 8),
              if (isCash)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openCashPaymentModal(context, order),
                    icon: const Icon(
                      Icons.payments_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Input Bayar Tunai (Kasir)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmPaymentModal(context, order),
                    icon: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Konfirmasi Pembayaran Lunas',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
