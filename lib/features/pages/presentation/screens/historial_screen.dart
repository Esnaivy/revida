import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:revida/config/theme/app_colors.dart';
import 'package:revida/features/pages/domain/entities/reciclaje.dart';
import 'package:revida/features/pages/presentation/cubits/image_db_revida/image_db_revida_cubit.dart';

class HistorialScreen extends StatefulWidget {
  static String name = 'historial';
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Reciclaje> _objects = [];
  String? selected;
  String search = '';

  @override
  void initState() {
    super.initState();
    context.read<ImageDbRevidaCubit>().loadReciclajes();
  }

  List<Reciclaje> get filteredObjects {
    return _objects.where((obj) {
      final matchesCategory = selected == null || obj.categoria == selected;
      return matchesCategory;
    }).toList();
  }

  Widget highlightText(String text) {
    if (search.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerSearch = search.toLowerCase();

    final startIndex = lowerText.indexOf(lowerSearch);

    if (startIndex == -1) {
      return Text(text);
    }

    final endIndex = startIndex + search.length;

    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppColors.onSurface(context)),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF11C95A),
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }

  Widget buildChip(String category) {
    final isSelected = selected == category;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        showCheckmark: false,
        label: Text(category),
        selected: isSelected,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.onSurface(context),
          fontWeight: FontWeight.w500,
        ),
        selectedColor: const Color(0xFF11C95A),
        backgroundColor: AppColors.inset(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (value) {
          setState(() {
            selected = value ? category : null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageDbRevidaCubit, ImageDbRevidaState>(
      builder: (context, state) {
        if (state is ImageDbRevidaInitial) {
          context.watch<ImageDbRevidaCubit>().loadReciclajes();
          const Center(child: Text("Aún no has escaneado residuos"));
        }

        if (state is ImageDbRevidaLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ImageDbRevidaLoaded) {
          _objects = state.reciclajes;

          return Scaffold(
            appBar: AppBar(title: const Text('Objetos Escaneados')),
            body: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  //Búsqueda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// FILTROS
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                buildChip('Plástico Reciclable 🥤'),
                                buildChip('Papel y Cartón 📦'),
                                buildChip('Metales / Latas 🥫'),
                                buildChip('Vidrio 🍾'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Lista de objetos
                  Expanded(
                    child: _objects.isEmpty
                        ? const Center(
                            child: Text("Aún no has escaneado residuos"),
                          )
                        : ListView.builder(
                            itemCount: filteredObjects.length,
                            itemBuilder: (context, index) {
                              final objeto = filteredObjects[index];
                              return ListTile(
                                title: highlightText(objeto.categoria),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(objeto.categoria),
                                    Text(
                                      objeto.date.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _objects[index].imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 50,
                                              height: 50,
                                              color: const Color.fromARGB(
                                                255,
                                                24,
                                                146,
                                                0,
                                              ),
                                              child: Icon(
                                                Icons.no_photography,
                                                color: Color(0xFFC0FFB3),
                                              ),
                                            ),
                                  ),
                                ),
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => buildSheet(objeto),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ImageDbRevidaError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }

  Widget buildSheet(Reciclaje objeto) => Container(
    padding: EdgeInsets.all(20),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              objeto.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.no_photography,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 15),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF11C95A), // Color verde
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Imprimir Detalles',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Text(
            'Detalles del Objeto: ${objeto.categoria}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Confianza: ${objeto.confianza * 100}%'),
          SizedBox(height: 5),
          // Text('Mensaje: ${objeto}'),
          SizedBox(height: 5),
          Text('Fecha: ${objeto.date}'),
          SizedBox(height: 5),
          Text('Categoría: ${objeto.categoria}'),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF11C95A), // Color verde
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}
